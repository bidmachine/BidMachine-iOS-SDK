//
//  BooleanTableViewCell.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class BooleanTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var booleanSwitch: UISwitch!

    var binding: ((BooleanEntity) -> ())?

    var entity: BooleanEntity? {
        didSet { update() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func update() {
        guard entity != nil else {
            return
        }
        booleanSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        titleLabel.text = entity!.info
        booleanSwitch.isOn = entity!.value ?? false
    }
    
    @objc private func switchChanged() {
        let updatedEntity = BooleanEntity(info:entity!.info, value:booleanSwitch.isOn)
        binding?(updatedEntity)
    }
}

extension BooleanTableViewCell: NibProvider {
    static let reuseIdentifier: String = "BooleanTableViewCellReuseID"

    static var nib: UINib {
        return UINib(nibName: "BooleanTableViewCell", bundle: Bundle(for: self))
    }
}


extension BooleanTableViewCell: BindingView {
    typealias T = BooleanEntity
}
