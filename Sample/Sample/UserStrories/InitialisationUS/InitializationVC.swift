//
//  InitializationVC.swift
//  ExampleOpenBids
//
//  Created by Yaroslav Skachkov on 10/16/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine


class InitializationVC: UIViewController {
    @IBOutlet weak var sellerIdTextField: UITextField!
    @IBOutlet weak var initializeAdButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sellerIdTextField.keyboardType = UIKeyboardType.numberPad
        sellerIdTextField.text = SdkContext.shared.sellerId
        setupNavigationBarTitle()
    }
    
    private func setupNavigationBarTitle() {
        let titleView = NavigationTitle.nib.instantiate(withOwner: self, options: nil).first as! NavigationTitle
        let width = 300
        titleView.frame = CGRect(origin:CGPoint.zero, size: CGSize(width: width, height: 500))
        navigationItem.titleView = titleView
        titleView.rootViewController = self
        titleView.update()
    }
    
    @IBAction func initializationVCTapped(_ sender: Any) {
        sellerIdTextField.resignFirstResponder()
    }
    
    @IBAction func initialiseSdk(_ sender: Any) {
        SdkContext.shared.sellerId = sellerIdTextField.text!
        BDMSdk.shared().restrictions = SdkContext.shared.restriction
        BDMSdk.shared().publisherInfo = SdkContext.shared.publisherInfo
        BDMSdk.shared().enableLogging = SdkContext.shared.appConfiguration.logging
        
        BDMSdk.shared().startSession(withSellerID:SdkContext.shared.sellerId,
                                     configuration:SdkContext.shared.configuration){
                                        SdkContext.shared.synchronise()
                                        print("BidMachine SDK was initialized")
        }
        let  tabBarVC: TabBarController? =  UIApplication.shared.mainStoryboard.instantiateVC()
        self.navigationController?.pushViewController(tabBarVC!, animated: true)
    }
    
    @IBAction func configureAdvanced(_ sender: UIButton) {
        let configurationVC : ConfigurationVC? =  UIApplication.shared.mainStoryboard.instantiateVC()
        
        self.navigationController?.present(configurationVC!, animated: true, completion: nil)
    }
}
