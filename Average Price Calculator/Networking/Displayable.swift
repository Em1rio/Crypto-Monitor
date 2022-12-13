//
//  Displayable.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 14.11.2022.
//

import Foundation
protocol Displayable {
    var nameLabelText: String { get }
    var symbolLabelText: String { get }
    var price: String { get }
    var id: String { get }
}
