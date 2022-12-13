//
//  DBRealmManager.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 22.11.2022.
//
// MARK: - Допилить чтобы работал
import Foundation
import RealmSwift

class DBRealmManager {
    
    static let shared = DBRealmManager()
    
    private init() {}
    
    let localRealm = try! Realm()
    
    func saveCategoryModel(model: CoinCategory) {
        try! localRealm.write {
            localRealm.add(model)
        }
    }
    
    func saveEveryModel(model: EveryBuying) {
        try! localRealm.write {
            localRealm.add(model)
        }
    }
    
//    func obtainCategory() {
//
//            let AllCategories = localRealm.objects(CoinCategory.self)
//        var quantityValue = AllCategories.filter("name == \(Any.Type)")
//
//        }
    
    
    
}
