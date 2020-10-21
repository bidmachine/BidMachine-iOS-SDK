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
                .compactMap { $0.adConfig() }
                .map { ($0, false) }
            DispatchQueue.main.async { completion(entities) }
        }
    }
}


fileprivate extension Dictionary
where Key == String, Value == Any {
    func adConfig() -> BDMAdNetworkConfiguration? {
        return BDMAdNetworkConfiguration.build { builder in
            let _ = (self["network_class"] as? String)
                .flatMap { NSClassFromString($0) }
                .flatMap { $0 as? BDMNetwork.Type }
                .flatMap { builder.appendNetworkClass($0) }
            let _ = (self["network"] as? String)
                .flatMap(builder.appendName)
            let _ = builder.appendInitializationParams(self)
            (self["ad_units"] as? [[String: Any]])?
                .forEach { data in
                    let _ = builder.appendAdUnit(
                        BDMAdUnitFormatFromString(data["format"] as? String),
                        data.filter { $0.key != "format" },
                        data.filter { $0.key != "format" }
                    )
            }
        }
    }
}


