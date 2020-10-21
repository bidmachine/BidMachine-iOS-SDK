//
//  HeaderView.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit


class HeaderView: UIView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    @IBAction private func headerTouched(_ sender: Any) {
        onUserInteract?()
    }
    
    open var section: Section? {
        didSet {
            self.titleLabel.text = section?.title.uppercased()
            if section?.state == .expanded {
                self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: .pi)
            }
        }
    }
    
    open var onUserInteract: (()->())?
    
    func animate() {
        UIView.animate(withDuration: 0.2) {
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: .pi)
        }
    }
}


extension HeaderView: NibProvider {
    static let reuseIdentifier = "HeaderViewReuseID"

    static var nib: UINib {
        return UINib(nibName: "HeaderView", bundle: Bundle(for: self))
    }    
}
