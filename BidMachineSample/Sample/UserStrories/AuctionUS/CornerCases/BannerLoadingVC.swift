//
//  BannerLoadingVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 1/21/19.
//  Copyright © 2019 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine

class BannerLoadingVC: UIViewController {
    
    private lazy var bannerView: BDMBannerView = {
        let bannerView = BDMBannerView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        return bannerView
    }()
    
    private lazy var request: BDMBannerRequest = {
        let request = BDMBannerRequest()
        return request
    }()
    
    @IBAction func turnOnBanner(_ sender: Any) {
        if self.view.subviews.contains(bannerView) {
            bannerView.removeFromSuperview()
        }
        configureBanner()
        request.perform(with: self)
        bannerView.populate(with: request)
    }
    
    private func configureBanner() {
        self.view.addSubview(bannerView)
        bannerView.delegate = self
        bannerView.rootViewController = self
        let size = CGSizeFromBDMSize(.size320x50)
        
        let widthConstraint = bannerView.widthAnchor.constraint(equalToConstant: size.width)
        let heightConstraint = bannerView.heightAnchor.constraint(equalToConstant: size.height)
        
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120),
            widthConstraint,
            heightConstraint
            ])
    }
}

extension BannerLoadingVC: BDMRequestDelegate {
    func requestDidExpire(_ request: BDMRequest) {
        __print("BDMRequestDelegate")
        ToastMaker.showToast(viewController: self, data: "Request did expired")
    }
    
    func request(_ request: BDMRequest, failedWithError error: Error) {
        __print("BDMRequestDelegate")
        ToastMaker.showToast(viewController: self, data: error)
    }
    
    func request(_ request: BDMRequest, completeWith info: BDMAuctionInfo) {
        __print("BDMRequestDelegate")
        ToastMaker.showToast(viewController: self, data: info)
    }
}

extension BannerLoadingVC: BDMBannerDelegate {
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
