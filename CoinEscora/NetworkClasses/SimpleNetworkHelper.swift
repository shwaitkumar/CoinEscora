//
//  SimpleNetworkHelper.swift
//  ModernPokedex
//
//  Created by Shwait Kumar on 18/01/23.
//

import Foundation

class SimpleNetworkHelper {
    static let shared = SimpleNetworkHelper()
    
    func get<T: Decodable>(fromUrl url: URL, customDecoder: JSONDecoder? = nil, completion: @escaping (T?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            guard let data = data else {
                assertionFailure("No error but also no data?!")
                completion(nil)
                return
            }
            
            let decoder = customDecoder ?? JSONDecoder()
            
            do {
                let decoded = try decoder.decode(T.self, from: data)
                completion(decoded)
            } catch {
                completion(nil)
                print(error)
            }
            
        }.resume()
    }
    
    func fetchCoins(completion: @escaping ([Coin]?) -> ()) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        self.get(fromUrl: URL(string: "https://api.coinpaprika.com/v1/coins/")!, customDecoder: decoder, completion: completion)
    }
    
    func fetchCoinDetail(id: String ,completion: @escaping (CoinDetail?) -> ()) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        self.get(fromUrl: URL(string: "https://api.coinpaprika.com/v1/coins/\(id)")!, customDecoder: decoder, completion: completion)
    }
}
