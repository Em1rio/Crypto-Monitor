//
//  CoinCategory.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 17.11.2022.
//

import Foundation
import RealmSwift

// _id сделть тикером как положено, и создать нормальный id для отслеживания по номерам
// Принимать измение за 24 часа

class CoinCategory: Object, IndexableObject {
    @Persisted(primaryKey: true) var _id: String
    @Persisted var symbol: String
    @Persisted var nameCoin: String
    @Persisted var coinQuantity: Decimal128?
    @Persisted var totalSpend: Decimal128?
    @Persisted var index: Int = 0
    
    @Persisted var coins: List<EveryBuying>
    

    
}

class EveryBuying: Object {
    @Persisted var coin: String
    @Persisted var transaction: String
    @Persisted var quantity: Decimal128?
    @Persisted var price: Decimal128?
    @Persisted var date: Date = Date()
    
    @Persisted(originProperty: "coins") var assignee: LinkingObjects<CoinCategory>
    
   
}
protocol IndexableObject: AnyObject {
    var index: Int { get set }
}



extension Results where Element: IndexableObject {

    func moveObject(from fromIndex: Int, to toIndex: Int) {

        let min = Swift.min(fromIndex, toIndex)
        let max = Swift.max(fromIndex, toIndex)

        let baseIndex = min

        var elementsInRange: [Element] = filter("index >= %@ AND index <= %@", min, max)
            .map { $0 }

        let source = elementsInRange.remove(at: fromIndex - baseIndex)
        elementsInRange.insert(source, at: toIndex - baseIndex)

        elementsInRange
            .enumerated()
            .forEach { (index, element) in
                element.index = index + baseIndex
            }
    }
    
}
