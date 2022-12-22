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
//    lazy var coinArrayCategory: Results<AllCoinsModel> = {self.realm.objects(AllCoinsModel.self)} ()
    lazy var allCoins: Results<AllCoinsModel> = {self.realm.objects(AllCoinsModel.self)} ()
   
//    var savedData: [AllCoinsModel] = []
//    var filteredData = [String]()
    weak var delegate: ViewControllerDelegate?
    
    
    
    @IBOutlet weak var tikerLabel: UILabel!
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
       
            
            
        
       
        
       

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        readBuyingArray()
        
    }

    func loadData() {
        guard allCoins.isEmpty == true else {return}
            if NetworkMonitor.shared.isConnected {
                print(NetworkMonitor.shared.connectionType)
                print(NetworkMonitor.shared.isConnected)
                fetchCoins()
            } else {
                print(NetworkMonitor.shared.connectionType)
                print(NetworkMonitor.shared.isConnected)
                print("test")
                showConnectionAlertHud()

            }
     
    }

    func readBuyingArray() {
        
        allCoins = realm.objects(AllCoinsModel.self)
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
        
    }
    func showConnectionAlertHud() {
        let hud = JGProgressHUD()
        hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(systemName: "wifi.slash")! )
        hud.indicatorView?.tintColor = .systemRed
        hud.textLabel.text = "Отсутсвует подключение к интернету"
        hud.show(in: view)
       
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
        tableView.deselectRow(at: indexPath, animated: true) //дл] того чтобы выбор был анимирован
        if allCoins.isEmpty {
            delegate?.update(text: "\(selectedItem!.nameLabelText)", text2: "\( selectedItem!.symbolLabelText)", text3: "\(selectedItem!.id)")
        } else {
            delegate?.update(text: "\(selectedItemOffline!.name)", text2: "\( selectedItemOffline!.symbol)", text3: "\(selectedItemOffline!.id)")
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
       
        self.dismiss(animated: true)
        
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "segue") {
//            let vc = segue.destination as? ViewController
//            vc?.nameFromAll = selectedItem!.nameLabelText
//            vc?.symbolFromAll = selectedItem!.symbolLabelText
//                }
//    }

   
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}






//extension AllCoinsTableViewController: UISearchBarDelegate {
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        self.filteredData.removeAll()
//        guard searchText != "" || searchText != " " else {
//            print("empty search")
//            return
//        }
//
//
//    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let coinName = searchBar.text else {return}
//        print(searchBar.text)
//        searchCoins(for: coinName)
//
//    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//      searchBar.text = nil
//      searchBar.resignFirstResponder()
//      items = coins
//      tableView.reloadData()
//    }
//}

extension AllCoinsTableViewController {
    func fetchCoins() {
        
        AF.request("https://api.coinlore.net/api/tickers/")
            .validate()
            .responseDecodable(of: AllCoins.self) { (response) in
        guard let coin = response.value else { return }
        self.coins = coin.data
        self.items = coin.data
        self.loadDataToRealm(allCoins: self.coins)
        self.tableView.reloadData()
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
        
       
    
        
        
    
        
    }
//    func searchCoins(for name: String) {
//        let url = "https://api.coinlore.net/api/tickers/"
//        //2
//        let parameters: [String: String] = ["search": name]
//        print(parameters)
//        //3
//        AF.request(url, parameters: parameters)
//          .validate()
//          .responseDecodable(of: AllCoins.self) { response in
//            //4
//              guard let coin = response.value else {return}
//
//              self.items = coin.data
//            self.tableView.reloadData()
//
//          }
//    }

