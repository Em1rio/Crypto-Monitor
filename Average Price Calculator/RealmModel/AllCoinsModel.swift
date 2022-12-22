//
//  AllCoinsModel.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 20.12.2022.
//

import Foundation
import RealmSwift

class AllCoinsModel: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var symbol: String
    @Persisted var name: String
}


