//
//  ListOfCryptoVC.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 16.12.2022.
//

import UIKit
import RealmSwift
import Alamofire

class ListOfCryptoVC: UIViewController {
    
    let realm = try! Realm()
    var buyingArray: Results<CoinCategory>!
    var notificationToken: NotificationToken?
    var selectedItem: CoinCategory?
    
    lazy var objects: Results<CoinCategory> = {
        let realm = try! Realm()
        return realm.objects(CoinCategory.self)
            .sorted(by: \.index, ascending: true)
    }()
    
    @IBOutlet var tableViewLabel: UITableView! {
        didSet {
            tableViewLabel.layer.borderColor = UIColor.systemGray5.cgColor
            tableViewLabel.layer.borderWidth = 0.5
        }
    }
    @IBOutlet weak var displayLabel: UILabel!

    @IBOutlet weak var allTimeLabel: UILabel!
    
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
       

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readBuyingArray()
        updateBalance()
    }
    func readBuyingArray() {
        
        buyingArray = realm.objects(CoinCategory.self)
        tableViewLabel.setEditing(false, animated: true)
        tableViewLabel.reloadData()
        
    }
    
    func updateBalance() {
        
        var totalCost: Decimal128 = 0.0
        var totalSpend: Decimal128 = 0.0
        var difference: Decimal128 = 0.0
        
       func getSomeObject() -> [CoinCategory]? {
            let objects = try! Realm().objects(CoinCategory.self).toArray(ofType: CoinCategory.self) as [CoinCategory]

            return objects.count > 0 ? objects : nil
        }
        let listOfCrypto = objects.toArray(ofType: CoinCategory.self)
        
        for item in listOfCrypto {
            var id: String = ""
            id = item._id
            var priceRightNow: Decimal128 = 0.0
            let request = AF.request("https://api.coinlore.net/api/ticker/?id=\(id)")
            request.responseDecodable(of: Coin.self) { [self] response in
                guard let coin = response.value else {return}
                do {
                    priceRightNow = try Decimal128(string: coin.first!.priceUsd)
                    let dbCoins = realm.objects(CoinCategory.self)
                    let realmQuery = dbCoins.where { //дает доступ ко всему рилму и к его всем элементам
                        $0._id == id
                    }
                    let quantity = realmQuery.first?.coinQuantity
                    totalCost += priceRightNow * quantity!
                    //print(FormatterStyle.shared.formatPercentAndAverage(inputValue: "\(totalCost)"))
                    displayLabel.text = FormatterStyle.shared.formatCurrency(inputValue: "\(totalCost)")
                    let spendings = realmQuery.first!.totalSpend!
                    totalSpend += spendings
                    let step1 = totalCost - totalSpend
                    let step2 = step1 / totalSpend
                    difference = step2 * 100
                    if difference > 0 {
                        allTimeLabel.textColor = UIColor.systemGreen
                        allTimeLabel.text = "\(FormatterStyle.shared.formatPercentAndAverage(inputValue: "\(difference)"))%"
                    } else {
                        allTimeLabel.textColor = UIColor.systemRed
                        allTimeLabel.text = "\(FormatterStyle.shared.formatPercentAndAverage(inputValue: "\(difference)"))%"
                    }
                }
                catch {
                    print("Failed with error \(error)")
                }
            }
        }
    }
    

  // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passToDetail" {
            if let indexPath = tableViewLabel.indexPathForSelectedRow {
                let destVC = segue.destination as! DetailViewController
                let categoryPressed = buyingArray[indexPath.row]
                destVC.nameFromList = categoryPressed.symbol
                destVC.totalFromList = categoryPressed.coinQuantity!
                destVC.fullNameFromList = categoryPressed.nameCoin
                
            }
        }
          // Надо разобраться с ценой и таблицей
        }

}

extension ListOfCryptoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
       
               
        let category = buyingArray[indexPath.row] //если надо развернуть, то используй .reversed()
        cell.textLabel?.text = category.nameCoin
        cell.detailTextLabel?.text = "Общее количество: \(FormatterStyle.shared.format(inputValue: "\(category.coinQuantity ?? 0)"))"
        cell.detailTextLabel?.text = "Общее количество: \(FormatterStyle.shared.format(inputValue: "\(category.coinQuantity ?? 0)"))"
       
        

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true) //для того чтобы выбор был анимирован
        
   }
    
    
    
}
extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}
