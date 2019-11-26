//
//  NativeVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 11/29/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine
import Toast_Swift

class NativeTableVC: UITableViewController {
    private struct Constants {
        static let contentTitle = "Lorem ipsum"
        static let contentDescription = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }
    private let native = BDMNativeAd()
    var request: BDMNativeAdRequest?
    var error: NSError?
    
    @IBOutlet var nativeAdExampleTV: UITableView!
    
    let fakeEntityArray: [TableViewContentEntity] = [
        TableViewContentEntity(image: UIImage(named: "ManPic")!, title: Constants.contentTitle, description: Constants.contentDescription),
        TableViewContentEntity(image: UIImage(named: "KittyPic")!, title: Constants.contentTitle, description: Constants.contentDescription),
        TableViewContentEntity(image: UIImage(named: "ManPic")!, title: Constants.contentTitle, description: Constants.contentDescription)
    ]
    
    var nativeAdArray: [BDMNativeAd] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nativeAdExampleTV.register(ContentTableViewCell.nib, forCellReuseIdentifier: ContentTableViewCell.reuseIdentifier)
        nativeAdExampleTV.register(NativeAdViewCell.nib, forCellReuseIdentifier: NativeAdViewCell.reuseIdentifier)
        native.delegate = self
        native.producerDelegate = self
        
        let req = request ?? BDMNativeAdRequest()
        native.make(req)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row.quotientAndRemainder(dividingBy: 20).remainder == 0 {
            let nativeAdViewCell = tableView.dequeueReusableCell(withIdentifier: NativeAdViewCell.reuseIdentifier, for: indexPath) as! NativeAdViewCell
            native.unregisterViews()
            native.present(on: nativeAdViewCell,
                           clickableViews: [],
                           adRendering: nativeAdViewCell,
                           controller: self,
                           error: &error)
            return nativeAdViewCell
        }
        
        let fakeCell = tableView.dequeueReusableCell(withIdentifier: ContentTableViewCell.reuseIdentifier, for: indexPath) as! ContentTableViewCell
        
        let entity = fakeEntityArray[Int.random(in: 0...2)]
        
        fakeCell.fakeIcon.image = entity.image
        fakeCell.fakeTitle.text = entity.title
        fakeCell.fakeDescription.text = entity.description
        
        return fakeCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row.quotientAndRemainder(dividingBy: 20).remainder == 0 {
            return 375
        }
        return 86
    }
}

extension NativeTableVC: BDMNativeAdDelegate {
    func nativeAd(_ nativeAd: BDMNativeAd, readyToPresentAd auctionInfo: BDMAuctionInfo) {
        tableView.reloadData()
        ToastMaker.showToast(viewController: self, data: auctionInfo)
    }
    
    func nativeAd(_ nativeAd: BDMNativeAd, failedWithError error: Error) {
        ToastMaker.showToast(viewController: self, data: error)
    }
}

extension NativeTableVC: BDMAdEventProducerDelegate {
    
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        ToastMaker.showToast(viewController: self, data: "Native ad impression")
    }
    func didProduceUserAction(_ producer: BDMAdEventProducer) {
        ToastMaker.showToast(viewController: self, data: "Native ad user interaction")
    }
}
