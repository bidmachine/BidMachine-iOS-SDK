//
//  ToastMaker.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 11/27/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import BidMachine
import Toast_Swift


class ToastMaker {
    private static let style: ToastStyle = {
        var style = ToastStyle()
        style.messageAlignment = .center
        return style
    }()
    
    static func showToast<T>(viewController: UIViewController, data: T) {
        if let string = data as? String {
            makeMessageToast(on: viewController, with:string)
        } else if let info = data as? BDMAuctionInfo {
            makeToastOnSuccess(by: viewController, with: info)
        } else if let error = data as? Error {
            makeToastOnFail(by: viewController, with:error)
        }
    }
    
    private static func makeToastOnSuccess(by viewController: UIViewController,
                                           with auctionInfo: BDMAuctionInfo) {
        guard SdkContext.shared.appConfiguration.toast else { return }
        viewController.view
            .makeToast("Request is sucessfull, click to see auction info", style: style) { [unowned viewController] didTap in
                guard didTap else { return }
                
                let auctionInfoVC: AuctionInfoVC? = UIApplication.shared.mainStoryboard.instantiateVC()
                auctionInfoVC!.auctionInfo = auctionInfo
                
                viewController.navigationController?.pushViewController(auctionInfoVC!, animated: true)
        }
    }
    
    private static func makeToastOnFail(by viewController: UIViewController,
                                        with error: Error) {
        guard SdkContext.shared.appConfiguration.toast else { return; }
        viewController.view
            .makeToast("Ad did failed to load with error: \(error.localizedDescription)", style: style)
    }
    
    private static func makeMessageToast(on viewController: UIViewController,
                                         with message: String) {
        guard SdkContext.shared.appConfiguration.toast else { return }
        viewController.view
            .makeToast(message, style: style)
    }
}


