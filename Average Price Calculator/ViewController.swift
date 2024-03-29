//
//  ViewController.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 06.11.2022.
//
import Foundation
import UIKit
import RealmSwift
import Alamofire
import JGProgressHUD


protocol ViewControllerDelegate: AnyObject {
    func update(coinName: String, coinSymbol: String, idCoin: String)
}

class ViewController: UIViewController, ViewControllerDelegate {
    
   
    
    let realm = try! Realm()
    lazy var coinArrayCategory: Results<CoinCategory> = {self.realm.objects(CoinCategory.self)} ()
    var coins: List<EveryBuying>!
 

    @IBOutlet weak var howManyCoinsLabel: UILabel!
    @IBOutlet var Keyboard: [UIButton]!{
        didSet{
            for button in Keyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var quantitiOrPriceLable: UISegmentedControl! 
    var coinsName = ""
    var coinTiker = ""
    var coinId = ""
    var howManyValue: Decimal128 = 0.00
    var costValue: Decimal128 = 0.0
    var stillTyping = false
    var segmentControlIsOn = false
    var userIsInTheMiddleOfTyping = false
    var nameFromAll: String = ""
    var symbolFromAll: String = ""
    var sellOrBuyMode = false
    var transaction: String = "Куплено"
    let color = CABasicAnimation(keyPath: "borderColor")
    var dotButtonPressed = false
    
    @IBOutlet weak var viewWithNumbers: MyCustomView!
    @IBOutlet var categoriesLabel: [UIButton]!{
        didSet{
            for button in categoriesLabel {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    

    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let destination = segue.destination as? AllCoinsTableViewController else { return }
            destination.delegate = self
        }
    
    func update(coinName: String, coinSymbol: String, idCoin: String) {
        guard stillTyping != false else {return}
        nameFromAll = coinName
        symbolFromAll = coinSymbol
        coinId = idCoin
        coinsName = nameFromAll
        coinTiker = symbolFromAll
        if sellOrBuyMode == false {
            BuyCategoryToDB()
            quantitiOrPriceLable.selectedSegmentIndex = 0
            coinsOrCostTyping(quantitiOrPriceLable as Any)
            showHud(status: "success")
        } else {
            SellCategoryToBD()
            quantitiOrPriceLable.selectedSegmentIndex = 0
            coinsOrCostTyping(quantitiOrPriceLable as Any)
            showHud(status: "failure")
        }


       
        
    }
    func showHud(status: String) {
        switch status {
        case "success":
            let hud = JGProgressHUD()
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.indicatorView?.tintColor = .systemGreen
           
            hud.show(in: view)
            hud.dismiss(afterDelay: 0.6)
        case "failure":
            let hud = JGProgressHUD()
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.hudView.backgroundColor = .systemGray
            hud.show(in: view)
            hud.dismiss(afterDelay: 0.6)
        default:
            break
        }
    }



    
    // MARK: - Lifecycle
    override func viewDidLoad() {
     super.viewDidLoad()
        

       
    
    }// end ViewDidLoad
    
   
    @IBAction func SellOrBuy(_ sender: UISegmentedControl) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            self.sellOrBuyMode = false
            transaction = "Куплено"
            color.fromValue = UIColor.red.cgColor
            color.toValue = UIColor.systemGreen.cgColor
            color.duration = 1
            color.repeatCount = 1
            viewWithNumbers.layer.borderWidth = 2
            viewWithNumbers.layer.borderColor = UIColor.systemGreen.cgColor
            viewWithNumbers.layer.add(color, forKey: "borderColor")
            
        case 1:
            self.sellOrBuyMode = true
            transaction = "Продано"
            color.fromValue = UIColor.systemGreen.cgColor
            color.toValue = UIColor.red.cgColor
            color.duration = 1
            color.repeatCount = 1
            viewWithNumbers.layer.borderWidth = 2
            viewWithNumbers.layer.borderColor = UIColor.red.cgColor
            viewWithNumbers.layer.add(color, forKey: "borderColor")
        default: break
        }
    }
    
    
    
    @IBAction func AllCoins(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segue", sender: self)
    }
    
    @IBAction func coinsOrCostTyping(_ sender: Any) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            self.howManyCoinsLabel.textColor = .black
            self.costLabel.textColor = .gray
            self.segmentControlIsOn = false
            self.stillTyping = false
        case 1:
            self.howManyCoinsLabel.textColor = .gray
            self.costLabel.textColor = .black
            self.segmentControlIsOn = true
            self.stillTyping = false
        default:
            break
      
        }
    }

   
    @IBAction func numberPressed(_ sender: UIButton) {
        let dotsCountQuantity = howManyCoinsLabel.text!.components(separatedBy: ".").count
        let dotsCountCost = costLabel.text!.components(separatedBy: ".").count
        
        //Ограничения ввода количества монет
        if howManyCoinsLabel.text?.first == "." {
            howManyCoinsLabel.text?.insert("0", at: howManyCoinsLabel.text!.startIndex)
        }
        if howManyCoinsLabel.text! == "00"{
            howManyCoinsLabel.text!.removeFirst()
        }
        if (dotsCountQuantity > 2) {howManyCoinsLabel.text!.remove(at: (howManyCoinsLabel.text!.index(before: howManyCoinsLabel.text!.endIndex)))}
        
        //Ограничения ввода стоимости
        if costLabel.text?.first == "." {
            costLabel.text?.insert("0", at: costLabel.text!.startIndex)
        }
        if costLabel.text! == "00"{
            costLabel.text!.removeFirst()
        }
        if dotsCountCost > 2 {costLabel.text!.remove(at: (costLabel.text!.index(before: costLabel.text!.endIndex)))}
        
        if segmentControlIsOn == false {
            let number = sender.currentTitle!
                if stillTyping {
                    if howManyCoinsLabel.text!.count < 10  {
                        howManyCoinsLabel.text = howManyCoinsLabel.text! + number
                    }
                }else {
                    howManyCoinsLabel.text = number
                    stillTyping = true
                }
        }
        else {
            let number = sender.currentTitle!
                if stillTyping {
                    if costLabel.text!.count < 10 {
                        costLabel.text = costLabel.text! + number
                    }
                }else {
                    costLabel.text = number
                    stillTyping = true
                }
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        if segmentControlIsOn == false {
            howManyCoinsLabel.text = "0"
            stillTyping = false
        } else {
            costLabel.text = "0"
            stillTyping = false
           
            
        }
      
        
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        guard stillTyping != false else {return}
        //настраиваем параметры
        let generator = UINotificationFeedbackGenerator() //Тактильная отдача при нажатии
        generator.notificationOccurred(.success)
        coinsName = sender.currentTitle!
        if coinsName == "Bitcoin" {
            coinTiker = "BTC"
            coinId = "90"
        } else if coinsName == "Cosmos" {
            coinTiker = "ATOM"
            coinId = "33830"
        } else if coinsName == "NEAR" {
            coinsName = "NEAR Protocol"
            coinTiker = "NEAR"
            coinId = "48563"
        } else if coinsName == "Solana" {
            coinTiker = "SOL"
            coinId = "48543"
        } else if coinsName == "Ethereum" {
            coinTiker = "ETH"
            coinId = "80"
        } else if coinsName == "Polkadot" {
            coinTiker = "DOT"
            coinId = "45219"
        } else if coinsName == "SAND" {
            coinTiker = "SAND"
            coinsName = "The Sandbox"
            coinId = "45161"
        }else if coinsName == "USDT" {
            coinTiker = "USDT"
            coinsName = "Tether"
            coinId = "518"
        }else if coinsName == "Cardano" {
            coinTiker = "ADA"
            coinsName = "Cardano"
            coinId = "257"
        } else {
        }
        if sellOrBuyMode == false {
            BuyCategoryToDB()
            quantitiOrPriceLable.selectedSegmentIndex = 0
            coinsOrCostTyping(quantitiOrPriceLable as Any)
            
        } else {
            SellCategoryToBD()
            quantitiOrPriceLable.selectedSegmentIndex = 0
            coinsOrCostTyping(quantitiOrPriceLable as Any)
        }

        

    }
    
    func BuyCategoryToDB () {
        guard howManyCoinsLabel.text != "." && costLabel.text != "." else {showHud(status: "failure"); howManyCoinsLabel.text = "0"; costLabel.text = "0"; return}
        guard howManyCoinsLabel.text != "0" && costLabel.text != "0" else {showHud(status: "failure"); howManyCoinsLabel.text = "0"; costLabel.text = "0"; return}
        howManyValue = Decimal128(floatLiteral: Double(howManyCoinsLabel.text!)!)
        costValue = Decimal128(floatLiteral: Double(costLabel.text!)!)
        howManyCoinsLabel.text = "0"
        costLabel.text = "0"
        stillTyping = false
        
        let value = EveryBuying(value: ["\(coinsName)", transaction, howManyValue, costValue])
        let parentCategory = CoinCategory()
        parentCategory._id = "\(coinId)"
        parentCategory.symbol = "\(coinTiker)"
        parentCategory.nameCoin = "\(coinsName)"
        let dbCoins = realm.objects(CoinCategory.self)
        let realmQuery = dbCoins.where { //дает доступ ко всему рилму и к его всем элементам
            $0._id == coinId
        }
        parentCategory.coinQuantity = howManyValue + (realmQuery.first?.coinQuantity ?? 0.0 )
        
        parentCategory.totalSpend = howManyValue * costValue
        parentCategory._id = "\(coinId)"
        parentCategory.symbol = "\(coinTiker)"
        parentCategory.nameCoin = "\(coinsName)"
        if realmQuery.first?.coins == nil {
            parentCategory.coins.append(objectsIn: [value])
            try! realm.write {
                realm.add([value])
                realm.add(parentCategory, update: .all)
            }
        } else {
            parentCategory.coins = realmQuery.first!.coins  //в новый объект добавляем старые данные из рилма
            parentCategory.totalSpend = (howManyValue * costValue) +  realmQuery.first!.totalSpend!
            parentCategory.coins.append(objectsIn: [value]) //добавляем новые данные
            try! realm.write {
                realm.add([value])
                realm.add(parentCategory, update: .all)
            }
        }
        showHud(status: "success")
        
    }
    
    func SellCategoryToBD () {
        guard howManyCoinsLabel.text != "." && costLabel.text != "." else {showHud(status: "failure"); howManyCoinsLabel.text = "0"; costLabel.text = "0"; return}
        guard howManyCoinsLabel.text != "0" && costLabel.text != "0" else {showHud(status: "failure"); howManyCoinsLabel.text = "0"; costLabel.text = "0"; return}
        let parentCategory = CoinCategory()
        guard parentCategory._id == coinId else {return }
        
        howManyValue = Decimal128(floatLiteral: Double(howManyCoinsLabel.text!)!)
        costValue = Decimal128(floatLiteral: Double(costLabel.text!)!)
        howManyCoinsLabel.text = "0"
        costLabel.text = "0"
        stillTyping = false
        

        let value = EveryBuying(value: ["\(coinsName)", transaction, howManyValue, costValue])
       
        parentCategory._id = "\(coinId)"
        parentCategory.symbol = "\(coinTiker)"
        parentCategory.nameCoin = "\(coinsName)" 
        let dbCoins = realm.objects(CoinCategory.self)
        let realmQuery = dbCoins.where { //дает доступ ко всему рилму и к его всем элементам
            $0._id == coinId
        }
        parentCategory.coinQuantity = (realmQuery.first?.coinQuantity ?? 0.0 ) - howManyValue

        parentCategory.totalSpend = howManyValue * costValue
        parentCategory._id = "\(coinId)"
        parentCategory.symbol = "\(coinTiker)"
        parentCategory.nameCoin = "\(coinsName)"
        if realmQuery.first?.coins == nil {
            parentCategory.coins.append(objectsIn: [value])
            try! realm.write {

                realm.add([value])
                realm.add(parentCategory, update: .all)
            }

        } else {
            parentCategory.coins = realmQuery.first!.coins  //в новый объект добавляем старые данные из рилма
            parentCategory.totalSpend = realmQuery.first!.totalSpend! - (howManyValue * costValue)
            parentCategory.coins.append(objectsIn: [value]) //добавляем новые данные
            try! realm.write {

                realm.add([value])
                realm.add(parentCategory, update: .all)
            }
        }
        showHud(status: "success")
    }
    
}






