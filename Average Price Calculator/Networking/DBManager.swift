//
//  DBManager.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 17.11.2022.
//
// MARK: - Или Этот допилить чтобы работал
import Foundation
import RealmSwift

//protocol DBManager {
//    func save(coin: Category)
//    func obtainCategory() -> [Category]
//}
//
//class DBManagerImpl: DBManager {
//    fileprivate lazy var mainRealm = try! Realm(configuration: .defaultConfiguration)
//    func save(coin: Category) {
//        try! mainRealm.write {
//            mainRealm.add(coin)
//        }
//    }
//    
//    func obtainCategory() -> [Category] {
//        let models = mainRealm.objects(Category.self)
//        return Array(models)
//    }
//}
