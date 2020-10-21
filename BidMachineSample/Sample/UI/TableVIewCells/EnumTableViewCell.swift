//
//  EnumTableViewCell.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

protocol BindingView {
    associatedtype T:Entity
    var entity: T? { get set } 
    var binding:((T)->())? {get set}
}

class EnumTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var enumSegmentedControl: UISegmentedControl!
    
    var binding:((T)->())?

    var entity:StringEnumEntity? {
        didSet { update() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }
    
    private func update() {
        guard entity != nil else {
            return
        }
        
        titleLabel.text = entity!.info
        enumSegmentedControl.removeAllSegments()
        for (index, element) in entity!.possibleValues.enumerated() {
            enumSegmentedControl.insertSegment(withTitle: element, at: index, animated: false)
            enumSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        }
        enumSegmentedControl.selectedSegmentIndex = entity?.value.flatMap{entity!.possibleValues.firstIndex(of: $0)} ?? 0
    }
    
    @objc private func segmentedControlValueChanged() {
        let value = enumSegmentedControl.titleForSegment(at: enumSegmentedControl.selectedSegmentIndex)
        let updateEntity = StringEnumEntity(info: entity!.info, value: value, possibleValues: entity!.possibleValues)
        binding?(updateEntity)
    }
}

extension EnumTableViewCell: NibProvider {
    static var nib: UINib {
        return UINib(nibName: "EnumTableViewCell", bundle: Bundle(for: self))
    }
    
    static var reuseIdentifier: String {
        return "EnumTableViewCellReuseID"
    }
}

extension EnumTableViewCell: BindingView {
    typealias T = StringEnumEntity
}
