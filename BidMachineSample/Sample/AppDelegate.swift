//
//  AppDelegate.swift
//  ExampleOpenBids
//
//  Created by Yaroslav Skachkov on 10/16/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        let selectedController = (window?.rootViewController as? UINavigationController)
            .flatMap { $0.topViewController }
            .flatMap { $0 as? TabBarController }
            .flatMap { $0.selectedViewController }
        switch selectedController {
        case is BannerVC, is InterstitialVC, is RewardedVideoVC: return .portrait
        default: return .all
        }
    }
}

extension AppDelegate: BDMAdEventProducerDelegate  {
    func didProduceImpression(_ producer: BDMAdEventProducer) {
        __print("BDMAdEventProducerDelegate")
    }
    
    func didProduceUserAction(_ producer: BDMAdEventProducer) {
        __print("BDMAdEventProducerDelegate")
    }
}

extension UIApplication {
    var mainStoryboard: UIStoryboard {
        get {
            return UIStoryboard(name: "Main", bundle: nil)
        }
    }
    
    var cornerCasesStoryboard:UIStoryboard {
        get {
            return UIStoryboard(name: "CornerCases", bundle: nil)
        }
    }
}

extension UIStoryboard {
    func instantiateVC<T: UIViewController>() -> T? {
        let name = String(describing: T.self)
        return instantiateViewController(withIdentifier: name) as? T 
    }
}
