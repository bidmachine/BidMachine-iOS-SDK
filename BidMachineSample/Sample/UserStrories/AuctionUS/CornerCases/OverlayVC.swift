//
//  OverlayVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/19/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine

class OverlayVC: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var bannerView: BDMBannerView!
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var overlayViewCenterPosition: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderValueLabel.text = "Adjust grey view position"
        bannerView.rootViewController = self
        bannerView.delegate = self
    }
    
    @IBAction func turnOnBanner(_ sender: Any) {
        let req = BDMBannerRequest()
        req.adSize = .size320x50
        bannerView.populate(with: req)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        overlayViewCenterPosition.constant = CGFloat(sender.value)
    }
}

extension OverlayVC: BDMBannerDelegate {
    func bannerViewDidExpire(_ bannerView: BDMBannerView) {
        __print("BDMBannerDelegate")
        ToastMaker.showToast(viewController: self, data: "Banner did expire")
    }
    
    func bannerViewReady(toPresent bannerView: BDMBannerView) {
        __print("BDMBannerDelegate")
        ToastMaker.showToast(viewController: self, data: "Banner ready to present")
    }
    
    func bannerViewRecieveUserInteraction(_ bannerView: BDMBannerView) {
        __print("BDMBannerDelegate")
        ToastMaker.showToast(viewController: self, data: "Banner recieve user interaction")
    }
    
    func bannerView(_ bannerView: BDMBannerView, failedWithError error: Error) {
        __print("BDMBannerDelegate")
        ToastMaker.showToast(viewController: self, data: error)
    }
}
