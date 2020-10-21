//
//  RewardedVideoVC.swift
//  Sample
//
//  Created by Stas Kochkin on 20/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine
import Toast_Swift


final class RewardedVideoVC: UIViewController {
    private let rewarded = BDMRewarded()

    private lazy var request: BDMRewardedRequest = {
        let request = BDMRewardedRequest()
        return request
    }()
    
    var style = ToastStyle()
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var presentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style.messageAlignment = .center
        rewarded.delegate = self
        rewarded.producerDelegate = UIApplication.shared.delegate as! AppDelegate
        presentButton.isEnabled = false
    }
    
    @IBAction func loadRewarded(_ sender: Any) {
        rewarded.populate(with: request)
    }
    
    @IBAction func presentRewarded(_ sender: Any) {
        guard rewarded.canShow else {
            print("Rewarded are not ready")
            return
        }
        
        rewarded.present(fromRootViewController: self)
    }
    
    @IBAction func presentStatusVC(_ sender: Any) {
        let statusVC: StatusVC? = UIApplication.shared.mainStoryboard.instantiateVC()
        statusVC?.adStatus = (rewarded.isLoaded, rewarded.canShow)
        navigationController?.pushViewController(statusVC!, animated: true)
    }
    
    @IBAction func prepareRequest(_ sender: Any) {
        request.perform(with: self)
    }
    
    @IBAction func configureRequest(_ sender: Any) {
        let requestVC: RewardedRequestVC? =  UIApplication.shared.mainStoryboard.instantiateVC()
        requestVC?.add(self.request)
        requestVC?.onUpdateRequest = { [unowned self] request in
            request.map { self.request = $0 }
        }
        navigationController?.present(requestVC!, animated: true, completion: nil)
    }
}


extension RewardedVideoVC: BDMRequestDelegate {
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


extension RewardedVideoVC: BDMRewardedDelegate {
    func rewardedReady(toPresent rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: "Rewarded ad ready to present")
        presentButton.isEnabled = true
    }
    
    func rewarded(_ rewarded: BDMRewarded, readyToPresentAd auctionInfo: BDMAuctionInfo) {
        __print("BDMRewardedDelegate")
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedWithError error: Error) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: error)
        presentButton.isEnabled = false
    }
    
    func rewarded(_ rewarded: BDMRewarded, failedToPresentWithError error: Error) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: error)
        presentButton.isEnabled = false
    }
    
    func rewardedWillPresent(_ rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: "Rewarded will present")
    }
    
    func rewardedDidExpire(_ rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: "Rewarded did expire")
        presentButton.isEnabled = false
    }
    
    func rewardedDidDismiss(_ rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: "Rewarded did dismiss")
        presentButton.isEnabled = false
    }
    
    func rewardedRecieveUserInteraction(_ rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: "Rewarded did receive user interaction")
    }
    
    func rewardedFinishRewardAction(_ rewarded: BDMRewarded) {
        __print("BDMRewardedDelegate")
        ToastMaker.showToast(viewController: self, data: "Rewarded finish reward action")
    }
}
