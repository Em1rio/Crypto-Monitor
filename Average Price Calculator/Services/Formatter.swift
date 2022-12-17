//
//  Formatter.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 06.12.2022.
//

import Foundation

class FormatterStyle {

    static let shared = FormatterStyle()

    private init() { }

    func format(inputValue: String) -> String {

        let value = Decimal(string: inputValue )
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 16
        return numberFormatter.string(for: value)!
    }
    func formatPercentAndAverage(inputValue: String) -> String {

        let value = Decimal(string: inputValue )
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(for: value)!
    }
    func formatCurrency(inputValue: String) -> String {
        let value = Decimal(string: inputValue)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.locale = Locale(identifier: "es_CL")
        return numberFormatter.string(for: value)!
    }
}

//MARK: - Сделать форматтер для валют
