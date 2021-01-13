//
//  HeaderBidding.swift
//  Sample
//
//  Created by Stas Kochkin on 16/07/2019.
//  Copyright © 2019 Yaroslav Skachkov. All rights reserved.
//

import Foundation
import BidMachine.HeaderBidding


typealias BDMAdNetworkConfigEntity = (config: BDMAdNetworkConfiguration, included: Bool)


final class HeaderBiddingProvider {
    static let shared: HeaderBiddingProvider = HeaderBiddingProvider()
    
    private var json: [[String: Any]] {
        return Bundle(for: HeaderBiddingProvider.self)
            .url(forResource: "HeaderBidding", withExtension: "json")
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as! [[String: Any]]
    }
    
    
    func getConfigEntities(completion: @escaping ([BDMAdNetworkConfigEntity]) -> Void) {
        DispatchQueue.global().async {
            let entities:[BDMAdNetworkConfigEntity] = self.json
                .compactMap { BDMAdNetworkConfiguration(json: $0) }
                .map { ($0, false) }
            DispatchQueue.main.async { completion(entities) }
        }
    }
}


