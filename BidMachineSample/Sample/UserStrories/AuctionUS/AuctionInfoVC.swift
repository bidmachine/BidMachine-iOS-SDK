//
//  AuctionInfoVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 11/26/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine

class AuctionInfoVC: UIViewController {
    var auctionInfo: BDMAuctionInfo?
    
    @IBOutlet weak var bidIdLabel: UILabel!
    @IBOutlet weak var demandSourceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cidLabel: UILabel!
    @IBOutlet weak var adDomainsLabel: UILabel!
    @IBOutlet weak var creativeIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let info = auctionInfo else {
            return
        }
        
        bidIdLabel.text = info.bidID
        demandSourceLabel.text = info.demandSource
        priceLabel.text = info.price?.stringValue
        creativeIdLabel.text = info.creativeID
        cidLabel.text = info.cID
        adDomainsLabel.text = info.adDomains?.joined(separator: ", ")
    }
}
