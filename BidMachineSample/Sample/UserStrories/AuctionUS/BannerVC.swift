//
//  BannerVC.swift
//  ExampleOpenBids
//
//  Created by Yaroslav Skachkov on 10/16/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine
import Toast_Swift


final class BannerVC: UIViewController {
    @IBOutlet weak var bannerSizeSegments: UISegmentedControl!
    
    private weak var widthConstraint: NSLayoutConstraint?
    private weak var heightConstraint: NSLayoutConstraint?
    
    private lazy var request: BDMBannerRequest = {
        let request = BDMBannerRequest()
        return request
    }()
    
    private lazy var bannerView: BDMBannerView = {
        let bannerView = BDMBannerView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        return bannerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView.delegate = self
        bannerView.producerDelegate = UIApplication.shared.delegate as! AppDelegate
        bannerView.rootViewController = self
    }
    
    @IBAction func loadBannerTapped(_ sender: Any) {
        selectBannerSize()
        bannerView.populate(with: request)
    }
    
    @IBAction func sizeDidChange(_ sender: Any) {
        let size: CGSize! = CGSizeFromBDMSize(currentBannerSize())
        widthConstraint?.constant = size.width
        heightConstraint?.constant = size.height
    }
    
    @IBAction func performRequest(_ sender: Any) {
        request.perform(with: self)
    }
    
    @IBAction func configureRequest(_ sender: Any) {
        let requestVC: BannerRequestVC? = UIApplication.shared.mainStoryboard.instantiateVC()
        requestVC?.add(self.request)
        requestVC?.onUpdateRequest = { [unowned self] request in
            request.map { self.request = $0 }
        }
        
        navigationController?.present(requestVC!, animated: true, completion: nil)
    }
    
    @IBAction func bannerSupperviewChanged(_ sender: UISwitch) {
        guard sender.isOn else {
            bannerView.removeFromSuperview()
            return
        }
        
        view.addSubview(bannerView)
        let size = CGSizeFromBDMSize(currentBannerSize())
        
        widthConstraint = bannerView.widthAnchor.constraint(equalToConstant: size.width)
        heightConstraint = bannerView.heightAnchor.constraint(equalToConstant: size.height)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            widthConstraint!,
            heightConstraint!
            ])
    }
    
    @IBAction func presentStatusVC(_ sender: Any) {
        let statusVC: StatusVC? = UIApplication.shared.mainStoryboard.instantiateVC()
        statusVC?.adStatus = (bannerView.isLoaded, bannerView.canShow)
        navigationController?.pushViewController(statusVC!, animated: true)
    }
    
    private func selectBannerSize() {
        self.request.adSize = currentBannerSize()
    }
    
    private func currentBannerSize() -> BDMBannerAdSize! {
        var size: BDMBannerAdSize!
        switch bannerSizeSegments.titleForSegment(at: bannerSizeSegments.selectedSegmentIndex) {
        case "iPhone": size = .size320x50
        case "iPad": size = .size728x90
        case "MREC": size = .size300x250
        default: size = .sizeUnknown
        }
        return size
    }
}

extension BannerVC: BDMRequestDelegate {
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

extension BannerVC: BDMBannerDelegate {
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
    
    func bannerViewWillPresentScreen(_ bannerView: BDMBannerView) {
        __print("BDMBannerDelegate")
        ToastMaker.showToast(viewController: self, data: "Banner will present screen")
    }
    
    func bannerViewWillLeaveApplication(_ bannerView: BDMBannerView) {
        __print("BDMBannerDelegate")
        ToastMaker.showToast(viewController: self, data: "Banner will leave application")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: BDMBannerView) {
        __print("BDMBannerDelegate")
        ToastMaker.showToast(viewController: self, data: "Banner did dismiss screen")
    }
}

