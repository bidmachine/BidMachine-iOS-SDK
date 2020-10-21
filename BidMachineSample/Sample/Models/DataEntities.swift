//
//  DataItem.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import Foundation
import BidMachine


protocol Entity: Equatable {
    associatedtype T
    var info: String? { get }
    var value:T? { get }
}


struct BooleanEntity : Entity {
    typealias T = Bool
    var info: String?
    var value:T?
    
    static func == (lhs: BooleanEntity, rhs: BooleanEntity) -> Bool {
        return lhs.info == rhs.info
    }
}


struct LocationEntity : Entity {
    typealias T = CLLocation
    var info: String?
    var value:T?

    static func == (lhs: LocationEntity, rhs: LocationEntity) -> Bool {
        return lhs.info == rhs.info
    }
}


struct StringEnumEntity : Entity {
    typealias T = String
    var info: String?
    var value:T?
    var possibleValues: [String]

    static func == (lhs: StringEnumEntity, rhs: StringEnumEntity) -> Bool {
        return lhs.info == rhs.info
    }
}


struct DictionaryEntity : Entity {
    typealias T = [String:Any]
    var info: String?
    var value:T?

    static func == (lhs: DictionaryEntity, rhs: DictionaryEntity) -> Bool {
        return lhs.info == rhs.info
    }
}


struct DataEntity : Entity {
    enum DataType {
        case string
        case url
        case numeric
        case commaSeparatedList
    }
    
    typealias T = String
    var info: String?
    var type: DataType
    var value:T?

    static func == (lhs: DataEntity, rhs: DataEntity) -> Bool {
        return lhs.info == rhs.info && lhs.type == rhs.type
    }
}


struct StatusEntity : Entity {
    typealias T = Bool
    var info: String?
    var value: T?

    static func == (lhs: StatusEntity, rhs: StatusEntity) -> Bool {
        return lhs.info == rhs.info
    }
}


struct OnlyLabelEntity : Entity {
    typealias T = String?
    var info: String?
    var value: T?
    
    static func == (lhs: OnlyLabelEntity, rhs: OnlyLabelEntity) -> Bool {
        return lhs.info == rhs.info
    }
}
