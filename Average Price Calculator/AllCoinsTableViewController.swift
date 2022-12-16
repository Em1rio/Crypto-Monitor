//
//  AllCoinsTableViewController.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 14.11.2022.
//

import UIKit
import Alamofire

class AllCoinsTableViewController: UITableViewController{
 
    
    var items: [Displayable] = []
    var selectedItem: Displayable?
    var coins: [Datum] = []
    
    var filteredData = [String]()
    weak var delegate: ViewControllerDelegate?
    
    
    @IBOutlet weak var tikerLabel: UILabel!
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCoins()
       
        
       

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
//        if ((indexPath.row % 2) != 0) {
//            cell.backgroundColor = UIColor.white
//        }else {
//            cell.backgroundColor = UIColor.systemGray5
//        }
        let item = items[indexPath.row]
        cell.textLabel?.text = item.nameLabelText
        cell.detailTextLabel?.text = item.symbolLabelText

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedItem = items[indexPath.row]
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //дл] того чтобы выбор был анимирован
        delegate?.update(text: "\(selectedItem!.nameLabelText)", text2: "\( selectedItem!.symbolLabelText)", text3: "\(selectedItem!.id)")
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
//        let request = AF.request("https://api.coinlore.net/api/tickers/")
//        request.responseDecodable(of: AllCoins.self) { (response) in
//            guard let coin = response.value else {return}
//            print(coin.data[0].name)
        AF.request("https://api.coinlore.net/api/tickers/")
            .validate()
            .responseDecodable(of: AllCoins.self) { (response) in
        guard let coin = response.value else { return }
        self.coins = coin.data
        self.items = coin.data
        self.tableView.reloadData()
                
        }
    }
    func searchCoins(for name: String) {
        let url = "https://api.coinlore.net/api/tickers/"
        //2
        let parameters: [String: String] = ["search": name]
        print(parameters)
        //3
        AF.request(url, parameters: parameters)
          .validate()
          .responseDecodable(of: AllCoins.self) { response in
            //4
              guard let coin = response.value else {return}
              
              self.items = coin.data
            self.tableView.reloadData()

          }
    }
}
