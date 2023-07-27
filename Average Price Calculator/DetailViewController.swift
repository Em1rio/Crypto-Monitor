//
//  DetailViewController.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 23.11.2022.
//

import UIKit
import RealmSwift
import Alamofire



class DetailViewController: UIViewController {
    
    var nameFromList: String = ""
    var totalFromList: Decimal128 = 0.0
    var fullNameFromList: String = ""
    var idFromList: String = ""
    var items: [Displayable] = []
    var jsonData: [Coin] = []
    let realm = try! Realm()
    lazy var buyingArray: Results<CoinCategory> = {self.realm.objects(CoinCategory.self)} ()
    var coins: List<EveryBuying>?
    //var item: EveryBuying?
    

    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var totalCostLabel: UILabel!
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var AveragePriceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var priceChange24: UILabel!
    
    @IBOutlet weak var priceChange: UILabel!
    func updateUI(balance: String) {
        symbolLabel.text = nameFromList
        nameLabel.text = fullNameFromList
        balanceLabel.text = "\(balance)"

        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(balance: "\(FormatterStyle.shared.format(inputValue: "\(totalFromList)"))")
        getAveragePrice()
        fetchMarketPrice()
       
        
        // Do any additional setup after loading the view.
    }
    //End of viewDidLoad
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func getAveragePrice() {
        //(Количество * на цену) + (количество * на цену) / на общее количество = средняя
        let dbCoins = realm.objects(CoinCategory.self)
        let realmQuery = dbCoins.where { //дает доступ ко всему рилму и к его всем элементам
            $0.nameCoin == nameLabel.text!
        }
        let quantity = realmQuery.first!.coinQuantity!
        let price = realmQuery.first!.totalSpend!
        let avrgPrice = price / quantity
        AveragePriceLabel.text = "\(FormatterStyle.shared.formatCurrency(inputValue: "\(avrgPrice)"))"
    }
    
    func fetchMarketPrice() {
        let dbCoins = realm.objects(CoinCategory.self)
        let realmQuery = dbCoins.where { //дает доступ ко всему рилму и к его всем элементам
            $0.nameCoin == nameLabel.text!
        }
        let coinId = realmQuery.first!._id
        
        let request = AF.request("https://api.coinlore.net/api/ticker/?id=\(coinId)")
        request.responseDecodable(of: Coin.self) { [self] (response) in
            guard let coin = response.value else {return}
            
            do {
                priceLabel.text =  "\(coin.first!.priceUsd)"
                priceLabel.text = priceLabel.text?.replacingOccurrences(of: "Optional(", with: "", options: NSString.CompareOptions.literal, range: nil)
                priceChange24.text = "\(coin.first!.percentChange24H)"
                priceChange24.text = priceChange24.text?.replacingOccurrences(of: "Optional(", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                let priceRightNow = try Decimal128(string: coin.first!.priceUsd)
                let totalSpend = realmQuery.first!.totalSpend!
                let quantity = realmQuery.first!.coinQuantity!
                let totalCost = priceRightNow * quantity
                totalCostLabel.text = "\(FormatterStyle.shared.format(inputValue: "\(totalCost)"))"
                let difference = (priceRightNow - (totalSpend / quantity)) / (totalSpend / quantity) * 100
                priceChange.text = "\(FormatterStyle.shared.formatPercentAndAverage(inputValue: "\(difference)"))%"
               
            }
            
            catch {
                print("Failed with error \(error)")
            }
            
        }
    }
    
    

    
    
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DBRealmManager.shared.getRealmQueryEB(nameLabel: nameLabel.text!).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailTableViewCell
        let coin = DBRealmManager.shared.getRealmQueryEB(nameLabel: nameLabel.text!)[indexPath.row]
        let neededDate = coin.date.getFormattedDate(format: "dd/MM/yyyy")
        cell.transactionLabel.text = "\(coin.transaction):"
        cell.quantityCellLabel.text = "\(FormatterStyle.shared.format(inputValue: "\(coin.quantity!)"))"
        cell.priceCellLabel.text = "\(FormatterStyle.shared.formatCurrency(inputValue: "\(coin.price!)"))"
        cell.dateCellLabel.text = "\(neededDate)"
        cell.totalCostCellLabel.text = "\(FormatterStyle.shared.formatCurrency(inputValue: "\(coin.price!.decimalNumberByMultiplying(by: coin.quantity!))"))"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true) //для того чтобы выбор был анимирован
        
   }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] (_, _, completionHandler) in
                let coin = DBRealmManager.shared.getRealmQueryEB(nameLabel: self.nameLabel.text!)[indexPath.row]
                    let category = CoinCategory()
                    //let dbCoins = realm.objects(CoinCategory.self)
                    let realmQuery = DBRealmManager.shared.getRealmQueryCoinCat(value: nameLabel.text!)
                    if coin.transaction == "Продано" {
                        category.coinQuantity = (realmQuery.first?.coinQuantity ?? 0.0 ) + coin.quantity!
                        category.totalSpend = (realmQuery.first?.totalSpend)! + (coin.quantity! * coin.price!)
                        category._id = "\(idFromList)"
                        category.nameCoin = "\(fullNameFromList)"
                        category.symbol = "\(nameFromList)"
                    } else {
                        category.coinQuantity = (realmQuery.first?.coinQuantity ?? 0.0 ) - coin.quantity!
                        print("coinQuantity update\(coin.quantity as Any)")
                        category.totalSpend = (realmQuery.first?.totalSpend)! - (coin.quantity! * coin.price!)
                        print("total spend update\(category.totalSpend as Any)")
                        category._id = "\(idFromList)"
                        category.nameCoin = "\(fullNameFromList)"
                        category.symbol = "\(nameFromList)"
                    }
                    
                    
                    try! self.realm.write {
                        self.realm.delete(coin)
                        self.realm.add(category, update: .all)
                    }
                    updateUI(balance: "\(category.coinQuantity!)")
                    getAveragePrice()
                    fetchMarketPrice()
                    tableView.reloadData()
                    completionHandler(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }
    
    
}
@IBDesignable extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = (newValue > 0)
        }
    }
    


}
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

