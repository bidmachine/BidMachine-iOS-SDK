//
//  NavigationTitle.swift
//  Sample
//
//  Created by Stas Kochkin on 19/12/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class NavigationTitle: UIButton {
    private struct AppInfo : Codable {
        var trackId : Int
        var trackCensoredName : String
        var trackViewUrl : String
        var trackName : String
        var sellerName : String
        var bundleId : String
        var version : String
        
        init() {
            trackId = 0
            trackCensoredName = ""
            trackViewUrl = ""
            trackName = "BidMachine"
            sellerName = ""
            bundleId = Bundle.main.bundleIdentifier!
            version = ""
        }
    }
    
    var rootViewController: UIViewController?
    
    public final func update() {
        self .setTitle( Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: #selector(titleTouched(_:)), for: .touchUpInside)
    }
    
    @objc private func titleTouched(_ sender: Any) {
        let alertController = UIAlertController(title: "Bundle swizzling", message: "Lookup app store data for bundle:", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "com.someapp.bundle"
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController, weak self] _ in
            let bundle = alertController?.textFields?.first?.text
            guard bundle != nil else {
                return
            }
            
            self?.getAppStoreInfo(bundle: bundle!) {
                self?.save($0)
            }
        }
        
        if let unarchivedAppInfo: AppInfo = NSKeyedUnarchiver.unarchiveCodable("appinfo") {
            let useCachedValue = UIAlertAction(title: "Use \(unarchivedAppInfo.trackName)", style: .default) { _ in
                self.save(unarchivedAppInfo)
            }
            alertController.addAction(useCachedValue)
        }
        
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func save(_ appData: AppInfo?) {
        Bundle.main.setSwizzled(appData?.bundleId)
        Bundle.main.setSwizzledDisplayName(appData?.trackName)
        Bundle.main.setSwizzledVersion(appData?.version)
        
        NSKeyedArchiver.archiveCodable(appData, "appinfo")
        
        SdkContext.shared.targeting.storeId = appData.flatMap { String($0.trackId) }
        SdkContext.shared.targeting.storeURL = appData.flatMap { URL(string: $0.trackViewUrl) }
        update()
    }
}

private extension NavigationTitle {
    enum ParsingError: Error {
        case NoData
    }
    
    private func getAppStoreInfo(bundle : String, closure : @escaping (AppInfo?) -> Void) {
        let infoLink : String! = String.init(format: "https://itunes.apple.com/lookup?bundleId=%@", bundle);
        let sessionManager : URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let request : URLRequest = URLRequest.init(url: URL(string: infoLink)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        sessionManager.dataTask(with: request) { [weak self] (data, response, error) in
            let info: AppInfo? = try! self?.appInfo(data)
            DispatchQueue.main.async {
                closure(info)
            }
        }.resume()
    }
    
    private func appInfo(_ fromResponseData: Data?) throws -> AppInfo {
        return try fromResponseData
            .flatMap { data -> Any in try JSONSerialization.jsonObject(with: data, options: .mutableContainers) }
            .flatMap { object -> [String: Any]? in (object as! [String:Any]).firstResult() }
            .flatMap { dict -> Data? in  try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) }
            .flatMap { data -> AppInfo? in try JSONDecoder().decode(AppInfo.self, from: data!) } ?? AppInfo()
    }
}

private extension Dictionary where Key == String, Value == Any {
    func firstResult() -> Dictionary? {
        guard let result = (self["results"] as? [Any])?.first as? [String:Any] else { return nil }
        return result
    }
}


extension NavigationTitle: NibProvider {
    static let reuseIdentifier: String = ""

    static var nib: UINib {
        return UINib(nibName: "NavigationTitle", bundle: Bundle(for: self.self))
    }
}
