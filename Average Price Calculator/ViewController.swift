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

protocol ViewControllerDelegate: AnyObject {
    func update(text: String, text2: String, text3: String)
}

class ViewController: UIViewController, ViewControllerDelegate {
    
   
    
    let realm = try! Realm()
    lazy var coinArrayCategory: Results<CoinCategory> = {self.realm.objects(CoinCategory.self)} ()
    var coins: List<EveryBuying>!
 
    @IBOutlet weak var segmentedControlLable: UISegmentedControl!
    @IBOutlet weak var howManyCoinsLabel: UILabel!
    @IBOutlet var Keyboard: [UIButton]!{
        didSet{
            for button in Keyboard {
                button.layer.cornerRadius = 11
            }
        }
    }
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var quantitiOrPriceLable: UISegmentedControl! {
        didSet {
            quantitiOrPriceLable.backgroundColor = UIColor.systemGray5
        }
    }
    
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
    
    @IBOutlet var categoriesLabel: [UIButton]!{
        didSet{
            for button in categoriesLabel {
                button.layer.cornerRadius = 11
            }
        }
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let destination = segue.destination as? AllCoinsTableViewController else { return }
            destination.delegate = self
        }
    
    func update(text: String, text2: String, text3: String) {
        nameFromAll = text
        symbolFromAll = text2
        coinId = text3
        coinsName = nameFromAll
        coinTiker = symbolFromAll
        if sellOrBuyMode == false {
            BuyCategoryToDB()
        } else {
            SellCategoryToBD()
        }
       
        
    }
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
     super.viewDidLoad()
        
//        var swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
//        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
//            self.view.addGestureRecognizer(swipeDown)
       
    
    }// end ViewDidLoad
    
//    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            
//            switch swipeGesture.direction {
//                
//            case UISwipeGestureRecognizer.Direction.down:
//                
//                print("Swiped Down")
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//
//                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "SellVC") as! ViewController
//
//                self.present(resultViewController, animated:true, completion:nil)
//            default:
//                break
//            }
//        }
//    }
   
    @IBAction func SellOrBuy(_ sender: UISegmentedControl) {
        switch (sender as AnyObject).selectedSegmentIndex {
        case 0:
            self.sellOrBuyMode = false
            transaction = "Куплено"
        case 1:
            self.sellOrBuyMode = true
            transaction = "Продано"
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
      // MARK: - Настроить возврат к дефолтному состоянию после выбора категории
        }
    }

   
    @IBAction func numberPressed(_ sender: UIButton) {
        // MARK: - Решить проблему с точкой и нулями, Возможно сделать больше кнопки, прилизать код
        guard howManyCoinsLabel.text != "." && costLabel.text != "." else {return resetButton(sender)}
        if segmentControlIsOn == false {
            let number = sender.currentTitle!
            if number == "0.00" && howManyCoinsLabel.text == "0.00" {
                stillTyping = false
            }
            else {
                if stillTyping {
                    if howManyCoinsLabel.text!.count < 10 {
                        howManyCoinsLabel.text = howManyCoinsLabel.text! + number
                    }
                }else {
                    howManyCoinsLabel.text = number
                    stillTyping = true
                }
            }
        }
        else {
            let number = sender.currentTitle!
            if number == "0.0" && costLabel.text == "0.0" {
                stillTyping = false
            } else {
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
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        if segmentControlIsOn == false {
            howManyCoinsLabel.text = "0.00"
            stillTyping = false
        } else {
            costLabel.text = "0.0"
            stillTyping = false
           
            
        }
      
        
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        //настраиваем параметры
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
        } else {
        }
        if sellOrBuyMode == false {
            BuyCategoryToDB()
        } else {
            SellCategoryToBD()
        }
        

    }
    
    func SellCategoryToBD () {
        print("Sell some crypto from DB")
        howManyValue = Decimal128(floatLiteral: Double(howManyCoinsLabel.text!)!)
        costValue = Decimal128(floatLiteral: Double(costLabel.text!)!)
        howManyCoinsLabel.text = "0.00"
        costLabel.text = "0.0"
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



    }
    
    func BuyCategoryToDB () {
       
        howManyValue = Decimal128(floatLiteral: Double(howManyCoinsLabel.text!)!)
        costValue = Decimal128(floatLiteral: Double(costLabel.text!)!)
        howManyCoinsLabel.text = "0.00"
        costLabel.text = "0.0"
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

        
    }
}





