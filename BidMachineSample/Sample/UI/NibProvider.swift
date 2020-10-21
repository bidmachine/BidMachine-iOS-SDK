//
//  NibProvider.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

protocol NibProvider {
    static var nib: UINib { get }
    static var reuseIdentifier: String { get }
}
