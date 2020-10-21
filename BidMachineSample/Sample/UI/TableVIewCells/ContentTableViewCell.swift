//
//  FakeCell.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 11/30/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    @IBOutlet weak var fakeIcon: UIImageView!
    @IBOutlet weak var fakeTitle: UILabel!
    @IBOutlet weak var fakeDescription: UILabel!
}

extension ContentTableViewCell: NibProvider {
    static let reuseIdentifier: String = "ContentTableViewCellReuseID"

    static var nib: UINib {
        return UINib(nibName: "ContentTableViewCell", bundle: Bundle(for: self))
    }    
}
