//
//  OneCoin.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 30.11.2022.
//

import Foundation


struct OneCoin: Decodable {
    let id, symbol, name, nameid: String
    let rank: Int
    let priceUsd, percentChange24H, percentChange1H, percentChange7D: String
    let marketCapUsd, volume24, volume24Native, csupply: String
    let priceBtc, tsupply, msupply: String

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, nameid, rank
        case priceUsd = "price_usd"
        case percentChange24H = "percent_change_24h"
        case percentChange1H = "percent_change_1h"
        case percentChange7D = "percent_change_7d"
        case marketCapUsd = "market_cap_usd"
        case volume24
        case volume24Native = "volume24_native"
        case csupply
        case priceBtc = "price_btc"
        case tsupply, msupply
    }
}

typealias Coin = [OneCoin]

//extension Coin: Displayable {
//    var symbolLabelText: String {
//        "\(symbol)"
//    }
//    
//    
//    
//    var price: String {
//        "\(priceUsd)"
//    }
//    
//    var nameLabelText: String {
//        name
//    }
//}
