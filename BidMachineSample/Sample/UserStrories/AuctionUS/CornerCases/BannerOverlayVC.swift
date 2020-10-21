//
//  BannerOverlayVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/19/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import  BidMachine

class BannerOverlayVC: UIViewController {
    
    private let rewarded = BDMRewarded()
    @IBOutlet weak var presentRewardedButton: UIButton!
    
    @IBOutlet weak var bannerView: BDMBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.delegate = self
        rewarded.delegate = self
        rewarded.producerDelegate = UIApplication.shared.delegate as! AppDelegate
        presentRewardedButton.isEnabled = false
        bannerView.rootViewController = self
    }
    
    @IBAction func turnOnBanner(_ sender: Any) {
        let req = BDMBannerRequest()
        req.adSize = .size320x50
        bannerView.populate(with: req)
    }
    
    @IBAction func loadRewardedVideo(_ sender: Any) {
        let req = BDMRewardedRequest()
        rewarded.populate(with: req)
    }
    
    @IBAction func presentRewarded(_ sender: Any) {
        guard rewarded.isLoaded else {
            print("Interstitial are not ready")
            return
        }
        
        rewarded.present(fromRootViewController: self)
    }
}


extension BannerOverlayVC : BDMRewardedDelegate {
    func rewardedReady(toPresent rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        presentRewardedButton.isEnabled = true
    }
    
    func rewardedDidExpire(_ rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        presentRewardedButton.isEnabled = false
    }
    
    func rewardedWillPresent(_ rewarded: BDMRewarded) {}
    func rewardedRecieveUserInteraction(_ rewarded: BDMRewarded) {}
    func rewardedFinishRewardAction(_ rewarded: BDMRewarded) {
        
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedWithError error: Error) {
        
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedToPresentWithError error: Error) {
        
    }
    
    func rewarded(_ rewarded: BDMRewarded, readyToPresentAd auctionInfo: BDMAuctionInfo) {
        __print("BDMRewardedDelegate")
        presentRewardedButton.isEnabled = true
    }
    func rewardedDidDismiss(_ rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        presentRewardedButton.isEnabled = false
    }
}

extension BannerOverlayVC: BDMBannerDelegate {
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
