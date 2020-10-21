//
//  VisibilityVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/19/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine

class VisibilityVC: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var bannerView: BDMBannerView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.rootViewController = self
        let req = BDMBannerRequest()
        req.adSize = .size320x50
        bannerView.populate(with: req)
    }
    
}
