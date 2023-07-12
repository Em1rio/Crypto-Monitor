//
//  ListOfCryptoTableVC.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 06.11.2022.
//

import UIKit
import RealmSwift
import Alamofire


class ListOfCryptoTableVC: UITableViewController{
    
    
    let realm = try! Realm()
    var buyingArray: Results<CoinCategory>!
    var notificationToken: NotificationToken?
    var selectedItem: CoinCategory?
    
    lazy var objects: Results<CoinCategory> = {
        let realm = try! Realm()
        return realm.objects(CoinCategory.self)
            .sorted(by: \.index, ascending: true)
    }()
    
    func observeObjects() {
        notificationToken = objects.observe { [weak self] change in
            guard let tableView = self?.tableView else {return}
            switch change {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.performBatchUpdates({
                    // Always apply updates in the following order: deletions, insertions, then modifications.
                    // Handling insertions before deletions may result in unexpected behavior.
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                }, completion: { finished in
                    // ...
                })
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    
        }
    

    //let dbManager: DBManager = DBManagerImpl()
    

    
    @IBOutlet var tableViewLabel: UITableView!
    @IBOutlet weak var nameCoinLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        observeObjects()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readBuyingArray()
        updateBalance()
      //  print(buyingArray!)
    }
    
    
 
    
    
    
    
    
    // MARK: - Table view data source

 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return buyingArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
       
               
        let category = buyingArray[indexPath.row] //если надо развернуть, то используй .reversed()
        cell.textLabel?.text = category.nameCoin
        cell.detailTextLabel?.text = "Общее количество: \(FormatterStyle.shared.format(inputValue: "\(category.coinQuantity ?? 0)"))"
        cell.detailTextLabel?.text = "Общее количество: \(FormatterStyle.shared.format(inputValue: "\(category.coinQuantity ?? 0)"))"
       
        

        return cell
    }

     
     func tableView(tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //дл] того чтобы выбор был анимирован
         
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let realm = try! Realm()

        try! realm.write {
            objects.moveObject(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
    
    
    func readBuyingArray() {
        
        buyingArray = realm.objects(CoinCategory.self)
        self.tableView.setEditing(false, animated: true)
        self.tableView.reloadData()
        
    }
    
    func updateBalance() {
       var id: [String] = []
       func getSomeObject() -> [CoinCategory]? {
            let objects = try! Realm().objects(CoinCategory.self).toArray(ofType: CoinCategory.self) as [CoinCategory]

            return objects.count > 0 ? objects : nil
        }
        let array = objects.toArray(ofType: CoinCategory.self)
        
      
        for item in array {
            var id: String = ""
            id = item._id
            let intId = Int(id)
            print(intId)
            let request = AF.request("https://api.coinlore.net/api/ticker/?id=\(intId!)")
            request.responseDecodable(of: Coin.self) { response in
                guard let coin = response.value else {return}
                do {
                    print(response)
                }
                
                catch {
                    print("Failed with error \(error)")
                }
                
            }
            
           id.append(item._id)
            
            
        }
        var intId = id.map {Int($0)!}
        print(intId)

    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passToDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
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
    
  
    
  
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    // Override to support rearranging the table view.
   
    

    
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

//extension Results {
//    func toArray<T>(ofType: T.Type) -> [T] {
//        var array = [T]()
//        for i in 0 ..< count {
//            if let result = self[i] as? T {
//                array.append(result)
//            }
//        }
//
//        return array
//    }
//}

