//
//  SdkContext.swift
//  Sample
//
//  Created by Stas Kochkin on 06/12/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine


class AppBehaviourConfiguration {
    var logging = true
    var toast = true
    var location = false
    var callbackLog = true
}


class SdkContext: NSObject {
    private struct Names {
        static let configuration = "BDMSdkConfiguration.txt"
        static let restriction = "BDMUserRestrictions.txt"
        static let publisher = "BDMPublisherInfo.txt"
        static let sellerId = "SellerID.txt"
        static let appInfo = "AppInfo.txt"
    }
    
    static let shared = SdkContext()
    
    // Base 64 consent string
    public let consentString = "DQO6WlgOQ7WlgABABwAAABJOACgACAAQABA"
    public var configuration: BDMSdkConfiguration
    public var targeting: BDMTargeting
    public var restriction: BDMUserRestrictions
    public var publisherInfo: BDMPublisherInfo
    public var sellerId: String
    public var appConfiguration: AppBehaviourConfiguration
    
    private var task: URLSessionDataTask?
    private var locationManager: CLLocationManager?
    
    public var currentLocation: CLLocation? {
        get { return locationManager?.location }
    }
    
    override init() {
        appConfiguration = AppBehaviourConfiguration()
        configuration = NSKeyedUnarchiver.unarchive(Names.configuration) ?? BDMSdkConfiguration()
        configuration.testMode = true
        targeting = configuration.targeting ?? BDMTargeting()
        restriction = NSKeyedUnarchiver.unarchive(Names.restriction) ?? BDMUserRestrictions()
        publisherInfo = NSKeyedUnarchiver.unarchive(Names.publisher) ?? BDMPublisherInfo()
        sellerId = UserDefaults.standard.object(forKey: Names.sellerId).map { $0 as! String } ?? "1"
        
        super.init()
    }
    
    public func synchronise() {
        if (appConfiguration.location) {
            startReceivingLocationChanges()
        }
        
        configuration.targeting = targeting
        NSKeyedArchiver.archive(configuration, Names.configuration)
        NSKeyedArchiver.archive(restriction, Names.restriction)
        NSKeyedArchiver.archive(publisherInfo, Names.publisher)
        UserDefaults.standard.set(sellerId, forKey: Names.sellerId)
        BDMSdk.shared().restrictions = restriction
    }
    
    private func startReceivingLocationChanges() {
        locationManager = CLLocationManager()
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            locationManager!.requestWhenInUseAuthorization()
        }
        
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        // Configure and start the service.
        locationManager!.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager!.distanceFilter = 100.0  // In meters.
        locationManager!.startUpdatingLocation()
    }
}


extension NSKeyedUnarchiver {
    class func unarchive<T:NSCoding>(_ name:String) -> T? {
        var model: T?
        let url = URL(fileURLWithPath: NSTemporaryDirectory().appending(name))
        let data = try? Data(contentsOf: url)
        if #available(iOS 11.0, *) {
            model = data.flatMap { try? unarchivedObject(ofClasses: [T.self], from: $0) as? T }
        } else {
            model = data.flatMap { unarchiveObject(with: $0) as? T }
        }
        
        return model
    }
}

extension NSKeyedArchiver {
    class func archive<T:NSCoding>(_ object:T, _ name:String) {
        let path = NSTemporaryDirectory().appending(name)
        var data: Data?
        if #available(iOS 11.0, *) {
            data = try? archivedData(withRootObject: object, requiringSecureCoding: false)
        } else {
            data = archivedData(withRootObject: object)
        }
        try? data?.write(to: URL(fileURLWithPath: path))
    }
}

extension NSKeyedUnarchiver {
    class func unarchiveCodable<T:Codable>( _ name:String) ->T? {
        var model: T?
        let url = URL(fileURLWithPath: NSTemporaryDirectory().appending(name))
        let data = try? Data(contentsOf: url)
        model = data.flatMap { try? JSONDecoder().decode(T.self, from: $0) }
        return model
    }
}

extension NSKeyedArchiver {
    class func archiveCodable<T:Codable>(_ object:T, _ name:String) {
        let path = NSTemporaryDirectory().appending(name)
        let data: Data? = try? JSONEncoder().encode(object)
        try? data?.write(to: URL(fileURLWithPath: path))
    }
}

