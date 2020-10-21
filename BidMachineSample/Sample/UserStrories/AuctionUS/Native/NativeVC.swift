//
//  NativeVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 11/30/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine

class NativeVC: UIViewController {
    private var request: BDMNativeAdRequest?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loadNative(_ sender: Any) {
        let nativeTableVC: NativeTableVC? = UIApplication.shared.mainStoryboard.instantiateVC()
        self.navigationController?.pushViewController(nativeTableVC!, animated: true)
        nativeTableVC?.request = self.request
    }
    
    @IBAction func presentStatusVC(_ sender: Any) {
        let statusVC: StatusVC? = UIApplication.shared.mainStoryboard.instantiateVC()
        navigationController?.pushViewController(statusVC!, animated: true)
    }
    
    @IBAction func configureRequest(_ sender: Any) {
        let requestVC: NativeAdRequestVC? =  UIApplication.shared.mainStoryboard.instantiateVC()
        
        navigationController?.present(requestVC!, animated: true, completion: nil)
    }
    
    
}
