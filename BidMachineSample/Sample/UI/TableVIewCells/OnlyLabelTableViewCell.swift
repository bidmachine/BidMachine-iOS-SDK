//
//  OnlyLabelTableViewCell.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/19/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit


class OnlyLabelTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    var entity: OnlyLabelEntity? {
        didSet {  update() }
    }
    
    var binding:((OnlyLabelEntity)->())?
    
    private func update() {
        label.text = entity?.info
    }
}

extension OnlyLabelTableViewCell: NibProvider {
    static let reuseIdentifier: String = "OnlyLabelTableViewCellReuseID"
    
    static var nib: UINib {
        return UINib(nibName: "OnlyLabelTableViewCell", bundle: Bundle(for: self))
    }
}

extension OnlyLabelTableViewCell: BindingView {
    typealias T = OnlyLabelEntity
}
