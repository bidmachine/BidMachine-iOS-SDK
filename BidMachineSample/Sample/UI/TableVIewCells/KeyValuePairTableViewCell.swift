//
//  KeyValuePairTableViewCell.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit


class KeyValuePairTableViewCell: UITableViewCell {
    @IBOutlet private weak var keyTextField: UITextField!
    @IBOutlet private weak var valueTextField: UITextField!
    @IBOutlet private weak var statusImageView: UIImageView!
    
    var binding:((T)->())?

    var entity: DictionaryEntity? {
        didSet { update() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        becomeFirstResponder()
        if let dict = parsedDictionary() {
            self.statusImageView.image = #imageLiteral(resourceName: "Correct")
            let updatedEntity = DictionaryEntity(info:entity!.info, value:dict)
            binding?(updatedEntity)
        } else {
            self.statusImageView.image = #imageLiteral(resourceName: "Incorrect")
        }
    }
    
    private func parsedDictionary() -> [String:String]? {
        let keys = keyTextField.text?.components(separatedBy: ", ")
        let values = valueTextField.text?.components(separatedBy: ", ")
        if (keys == nil || values == nil || (keys!.count == values!.count) == false) {
            return nil
        }
        var dict = [String:String]()
        keys?.enumerated().forEach{ dict[$0.element] = values![$0.offset] }
        return dict
    }
    
    private func update() {
        guard entity != nil else { return }
        self.statusImageView.image = parsedDictionary() == nil ? #imageLiteral(resourceName: "Incorrect") : #imageLiteral(resourceName: "Correct")
    }
}


extension KeyValuePairTableViewCell: NibProvider {
    static let reuseIdentifier: String = "KeyValuePairTableViewCellReuseID"

    static var nib: UINib {
        return UINib(nibName: "KeyValuePairTableViewCell", bundle: Bundle(for: self))
    }
}


extension KeyValuePairTableViewCell: BindingView {
    typealias T = DictionaryEntity
}
