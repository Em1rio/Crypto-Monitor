//
//  AllCoinsTableViewController.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 14.11.2022.
//

import UIKit
import Alamofire
import RealmSwift
import JGProgressHUD



class AllCoinsTableViewController: UITableViewController{
 
    
    var items: [Displayable] = []
    var selectedItem: Displayable?
    var selectedItemOffline: AllCoinsModel?
    var coins: [Datum] = []
    let realm = try! Realm()
    lazy var allCoins: Results<AllCoinsModel> = {self.realm.objects(AllCoinsModel.self)} ()
    let userDefaults = UserDefaults()

    weak var delegate: ViewControllerDelegate?
    
    
    
    //@IBOutlet weak var tikerLabel: UILabel!
   // let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        howOldDB()
        loadData()
        readDB()
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allCoins.isEmpty {
            return items.count    }
        else {
            return allCoins.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        if allCoins.isEmpty {
            let item = items[indexPath.row]
            cell.textLabel?.text = item.nameLabelText
            cell.detailTextLabel?.text = item.symbolLabelText
        } else {
            let item = allCoins[indexPath.row]
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.symbol
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if allCoins.isEmpty {
            selectedItem = items[indexPath.row]
        } else {
            selectedItemOffline = allCoins[indexPath.row]
        }
        return indexPath
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if allCoins.isEmpty {
            delegate?.update(coinName: "\(selectedItem!.nameLabelText)", coinSymbol: "\( selectedItem!.symbolLabelText)", idCoin: "\(selectedItem!.id)")
        } else {
            delegate?.update(coinName: "\(selectedItemOffline!.name)", coinSymbol: "\( selectedItemOffline!.symbol)", idCoin: "\(selectedItemOffline!.id)")
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        self.dismiss(animated: true)
    }
}

extension AllCoinsTableViewController {
    func howOldDB() {
        guard NetworkMonitor.shared.isConnected == true else {return}
        let date = Date()
        if UserDefaults.standard.object(forKey: "lastUpdate") as? Date == nil {
            //save
            UserDefaults.standard.set(date, forKey: "lastUpdate")
        } else {
            // read
            let lastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as! Date
            let timeInterval = date.timeIntervalSince(lastUpdate) / 86400
            // update
            if timeInterval >= 14 {
                UserDefaults.standard.set(date, forKey: "lastUpdate")
                fetchCoins()
            }
        }
    }
    
    func loadData() {
        guard allCoins.isEmpty == true else {return}
            if NetworkMonitor.shared.isConnected {
                fetchCoins()
            } else {
                showConnectionAlertHud()
            }
    }
    
    func readDB() {
        
        allCoins = realm.objects(AllCoinsModel.self)
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
    }
    
    func fetchCoins() {
        guard NetworkMonitor.shared.isConnected == true else {return}
        let hud = JGProgressHUD()
        hud.textLabel.text = "Загрузка"
        hud.show(in: self.view)
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            AF.request("https://api.coinlore.net/api/tickers/")
                .validate()
                .responseDecodable(of: AllCoins.self) { (response) in
                    guard let coin = response.value else { return }
                    self.coins = coin.data
                    self.items = coin.data
                    self.loadDataToRealm(allCoins: self.coins)
                    self.tableView.reloadData()
                    hud.dismiss()
                }
        }
    }
    
    func loadDataToRealm(allCoins: [Datum]) {
        let countedData = coins.count
        for item in 0...countedData-1 {
            let newData = AllCoinsModel()
            newData.id = coins[item].id
            newData.symbol = coins[item].symbol
            newData.name = coins[item].name
            
            try! realm.write {
                realm.add(newData, update: .all)
            }
        }
    }
    
    func showConnectionAlertHud() {
        let hud = JGProgressHUD()
        hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(systemName: "wifi.slash")! )
        hud.indicatorView?.tintColor = .systemRed
        hud.textLabel.text = "Отсутсвует подключение к интернету"
        hud.show(in: view)
    }
}


