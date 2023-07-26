//
//  DBRealmManager.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 22.11.2022.
//
// MARK: - Допилить чтобы работал
import Foundation
import RealmSwift

final class DBRealmManager {
    
    static let shared = DBRealmManager()
    
    private init() {}
    
    let localRealm = try! Realm()
    

    func getRealmQueryEB(nameLabel label: String) -> Results<EveryBuying>{
        let dbCoins = localRealm.objects(EveryBuying.self)
        let realmQuery = dbCoins.where { //дает доступ ко всему рилму и к его всем элементам
            $0.coin == label
        }
        return realmQuery
    }
    func getRealmQueryCoinCat(value: String) -> Results<CoinCategory>{
        let dbCoins = localRealm.objects(CoinCategory.self)
        let realmQuery = dbCoins.where { //дает доступ ко всему рилму и к его всем элементам
            $0.nameCoin == value
        }
        return realmQuery
    }
    
    func save(value1: EveryBuying, value2: CoinCategory) {
        try! localRealm.write {
            localRealm.add([value1])
            localRealm.add(value2, update: .all)
        }
    }
    
    
    
//    func saveEveryModel(model: EveryBuying) {
//        try! localRealm.write {
//            localRealm.add(model)
//        }
//    }
    
//    func obtainCategory() {
//
//            let AllCategories = localRealm.objects(CoinCategory.self)
//        var quantityValue = AllCategories.filter("name == \(Any.Type)")
//
//        }
    
    
    
}
