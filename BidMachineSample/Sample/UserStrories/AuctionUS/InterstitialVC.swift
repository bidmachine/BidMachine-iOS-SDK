//
//  FullscreenVC.swift
//  ExampleOpenBids
//
//  Created by Yaroslav Skachkov on 10/16/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine
import Toast_Swift

class InterstitialVC: UIViewController {
    private let interstitial = BDMInterstitial()
    
    private lazy var request: BDMInterstitialRequest = {
        let request = BDMInterstitialRequest()
        return request
    }()
    
    var style = ToastStyle()
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var presentButton: UIButton!
    
    @IBOutlet fileprivate weak var bannerSwitch: UISwitch!
    @IBOutlet fileprivate weak var videoSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style.messageAlignment = .center
        interstitial.delegate = self
        interstitial.producerDelegate = UIApplication.shared.delegate as! AppDelegate
        presentButton.isEnabled = false
    }
    
    @IBAction func loadIntersitial(_ sender: Any) {
        request.type = selectedType
        interstitial.populate(with: request)
    }
    
    @IBAction func presentInterstitial(_ sender: Any) {
        guard interstitial.canShow else {
            print("Interstitial are not ready")
            return
        }
        
        interstitial.present(fromRootViewController: self)
    }
    
    @IBAction func presentStatusVC(_ sender: Any) {
        let statusVC: StatusVC? = UIApplication.shared.mainStoryboard.instantiateVC()
        statusVC?.adStatus = (interstitial.isLoaded, interstitial.canShow)
        navigationController?.pushViewController(statusVC!, animated: true)
    }
    
    @IBAction func prepareRequest(_ sender: Any) {
        request.type = selectedType
        request.perform(with: self)
    }
    
    @IBAction func configureRequest(_ sender: Any) {
        let requestVC: InterstitialRequestVC? =  UIApplication.shared.mainStoryboard.instantiateVC()
        requestVC?.add(self.request)
        requestVC?.onUpdateRequest = { [unowned self] request in
            request.map { self.request = $0 }
        }
        
        navigationController?.present(requestVC!, animated: true, completion: nil)
    }
}


extension InterstitialVC {
    func updateSwitches() {
        videoSwitch.setOn(request.type.contains(.fullscreenAdTypeVideo), animated: true)
        bannerSwitch.setOn(request.type.contains(.fullsreenAdTypeBanner), animated: true)
    }
    
    var selectedType: BDMFullscreenAdType {
        get {
            var type = BDMFullscreenAdType()
            if videoSwitch.isOn {
                type.formUnion(.fullscreenAdTypeVideo)
                
            }
            if bannerSwitch.isOn {
                type.formUnion(.fullsreenAdTypeBanner)
            }
            return type
        }
    }
}


extension InterstitialVC: BDMRequestDelegate {
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

extension InterstitialVC: BDMInterstitialDelegate {
    func interstitialReady(toPresent interstitial: BDMInterstitial) {
        __print("BDMInterstitialDelegate")
        presentButton.isEnabled = true
        ToastMaker.showToast(viewController: self, data: "Interstitial ready to present creative")
    }
    
    func interstitial(_ interstitial: BDMInterstitial, readyToPresentAd auctionInfo: BDMAuctionInfo) {
        __print("BDMInterstitialDelegate")
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedWithError error: Error) {
        __print("BDMInterstitialDelegate")
        presentButton.isEnabled = false
        ToastMaker.showToast(viewController: self, data: error)
    }
    
    func interstitial(_ interstitial: BDMInterstitial, failedToPresentWithError error: Error) {
        __print("BDMInterstitialDelegate")
        presentButton.isEnabled = false
        ToastMaker.showToast(viewController: self, data: error)
    }
    
    func interstitialWillPresent(_ interstitial: BDMInterstitial) {
        __print("BDMInterstitialDelegate")
        presentButton.isEnabled = false
        ToastMaker.showToast(viewController: self, data: "Interstitial will present")
    }
    
    func interstitialDidExpire(_ interstitial: BDMInterstitial) {
        __print("BDMInterstitialDelegate")
        presentButton.isEnabled = false
        ToastMaker.showToast(viewController: self, data: "Interstitial did expired")
    }
    
    func interstitialDidDismiss(_ interstitial: BDMInterstitial) {
        __print("BDMInterstitialDelegate")
        presentButton.isEnabled = false
        ToastMaker.showToast(viewController: self, data: "Interstitial did dismiss")
    }
    
    func interstitialRecieveUserInteraction(_ interstitial: BDMInterstitial) {
        __print("BDMInterstitialDelegate")
        ToastMaker.showToast(viewController: self, data: "Interstitial revieve user interaction")
    }
}
