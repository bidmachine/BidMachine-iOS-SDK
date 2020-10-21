//
//  LabelAndImageTableViewCell.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/6/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit


class StatusTableViewCell: UITableViewCell {
    @IBOutlet weak var statusOptionLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    var binding:((StatusEntity)->())?

    var entity: StatusEntity? {
        didSet { update() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }
    
    private func update() {
        statusOptionLabel.text = entity?.info
        statusImageView.image = entity?.value ?? false ? UIImage(named: "Correct") : UIImage(named: "Incorrect")
    }
}


extension StatusTableViewCell: NibProvider {
    static let reuseIdentifier: String = "StatusTableViewCellReuseID"

    static var nib: UINib {
        return UINib(nibName: "StatusTableViewCell", bundle: Bundle(for: self))
    }
}


extension StatusTableViewCell: BindingView {
    typealias T = StatusEntity
}
