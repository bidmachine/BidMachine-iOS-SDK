//
//  DataTableViewCell.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var userInputTextField: UITextField!
    @IBOutlet private weak var statusImageView: UIImageView!
    
    var binding: ((DataEntity) -> ())?

    var entity: DataEntity? {
        didSet { update() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userInputTextField.returnKeyType = .done
        userInputTextField.delegate = self
        update()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        becomeFirstResponder()
    }
    
    fileprivate func validate() -> Bool {
        if self.userInputTextField?.text?.count ?? 0 > 0 {
            self.statusImageView.image = UIImage(named: "Correct")
            return true
        } else {
            self.statusImageView.image = UIImage(named: "Incorrect")
            return false
        }
    }
    
    private func update() {
        guard let entity = entity else { return }
        userInputTextField.setDataType(entity.type)
        titleLabel.text = entity.info
        userInputTextField.text = entity.value
        let _ = validate()
    }
}


extension DataTableViewCell: NibProvider {
    static let reuseIdentifier: String = "DataTableViewCellCellReuseID"

    static var nib: UINib {
        return UINib(nibName: "DataTableViewCell", bundle: Bundle(for: self))
    }    
}


extension DataTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if validate() {
            let updatedEntity = DataEntity(info: entity!.info, type:entity!.type, value:textField.text)
            binding?(updatedEntity)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension DataTableViewCell: BindingView {
    typealias T = DataEntity
}
