//
//  GeneratableDataTableViewCell.swift
//  Sample
//
//  Created by Stas Kochkin on 12/12/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class GeneratableDataTableViewCell: UITableViewCell {
    typealias EntityGenerationComplitionCallback = (DataEntity) -> ()
    typealias EntityGenerationAction = (DataEntity, @escaping EntityGenerationComplitionCallback)->()
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var userInputTextField: UITextField!
    @IBOutlet private weak var statusImageView: UIImageView!
    
    var entity: DataEntity? {
        didSet { update() }
    }
    
    var binding: ((DataEntity) -> ())?
    var generate:(EntityGenerationAction)?
    
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
    
    @IBAction func generateTouched(_ sender:Any) {
        let updatedEntity = DataEntity(info: entity!.info, type:entity!.type, value:userInputTextField.text)
        generate?(updatedEntity, { [weak self] entity in
            self?.entity = entity
            self?.update()
            self?.binding?(entity)
        })
    }
    
    private func update() {
        guard let entity = entity else { return }
        userInputTextField.setDataType(entity.type)
        titleLabel.text = entity.info
        userInputTextField.text = entity.value
        let _ = validate()
    }
}


extension GeneratableDataTableViewCell: NibProvider {
    static let reuseIdentifier: String = "GeneratableDataTableViewCellReuseID"
    
    static var nib: UINib {
        return UINib(nibName: "GeneratableDataTableViewCell", bundle: Bundle(for: self))
    }
}


extension GeneratableDataTableViewCell: UITextFieldDelegate {
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


extension GeneratableDataTableViewCell: BindingView {
    typealias T = DataEntity
}
