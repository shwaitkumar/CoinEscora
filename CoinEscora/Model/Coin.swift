//
//  Coin.swift
//  CoinEscora
//
//  Created by Shwait Kumar on 25/01/23.
//

import Foundation

struct Coin: Decodable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let rank: Int
    let isNew: Bool
    let isActive: Bool
    let type: String
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
