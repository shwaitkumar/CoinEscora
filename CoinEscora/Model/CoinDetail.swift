//
//  CoinDetail.swift
//  CoinEscora
//
//  Created by Shwait Kumar on 26/01/23.
//

import Foundation

struct CoinDetail: Decodable, Hashable {
    let id: String
    let name: String?
    let symbol: String?
    let rank: Int?
    let isNew: Bool?
    let isActive: Bool?
    let type: String?
    let contract: String?
    let platform: String?
    let contracts: [Contracts]?
    let logo: URL?
    let parent: Parent?
    let tags: [Tags]?
    let team: [Team]?
    let description: String?
    let message: String?
    let openSource: Bool?
    let startedAt: String?
    let developmentStatus: String?
    let hardwareWallet: Bool?
    let proofType: String?
    let orgStructure: String?
    let hashAlgorithm: String?
    let links: Links?
    let linksExtended: [LinksExtended]?
    let whitepaper: Whitepaper?
    let firstDataAt: String?
    let lastDataAt: String?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

struct Contracts: Decodable, Hashable {
    let contract: String?
    let platform: String?
    let type: String?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.contract == rhs.contract
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(contract)
    }
}

struct Parent: Decodable, Hashable {
    let id: String?
    let name: String?
    let symbol: String?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Tags: Decodable, Hashable {
    let id: String?
    let name: String?
    let coinCounter: Int?
    let icoCounter: Int?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Team: Decodable, Hashable {
    let id: String?
    let name: String?
    let position: String?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Links: Decodable, Hashable {
    let explorer: [URL]?
    let facebook: [URL]?
    let reddit: [URL]?
    let sourceCode: [URL]?
    let website: [URL]?
    let youtube: [URL]?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.explorer == rhs.explorer
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(explorer)
    }
}

struct LinksExtended: Decodable, Hashable {
    let url: URL?
    let type: String?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

struct Whitepaper: Decodable, Hashable {
    let link: URL?
    let thumbnail: URL?
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.link == rhs.link
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(link)
    }
}
