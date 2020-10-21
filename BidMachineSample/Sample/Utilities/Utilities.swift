//
//  Utilities.swift
//  Sample
//
//  Created by Stas Kochkin on 11/12/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import Foundation
import UIKit
import os.log


func __print(_ module: String, function: String = #function) {
    guard SdkContext.shared.appConfiguration.callbackLog else {
        return
    }
    
    NSLog("[Callback][%@] Recieve method: %@", module, function)
}

extension UITableViewCell.AccessoryType {
    mutating func `switch`() {
        switch self {
        case .none: self = .checkmark
        case .checkmark: self = .none
        default: break
        }
    }
    
    var marked: Bool { return self == .checkmark }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func commaSeparatedList() -> [String] {
        return components(separatedBy: ", ")
    }
}

extension UITextField {
    func setDataType(_ dataType: DataEntity.DataType) {
        switch dataType {
        case .commaSeparatedList:
            keyboardType = .default
            placeholder = "Comma separated list"
            break
        case .numeric:
            keyboardType = .numberPad
            placeholder = "Numeric value"
            break
        case .string:
            keyboardType = .default
            placeholder = "String value"
            break
        case .url:
            keyboardType = .URL
            placeholder = "URL value"
            break
        }
    }
}
