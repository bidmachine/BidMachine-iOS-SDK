//
//  LocationTableViewCell.swift
//  Sample
//
//  Created by Stas Kochkin on 30/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import CoreLocation


class LocationTableViewCell: UITableViewCell {
    @IBOutlet private weak var latTextField: UITextField!
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var lonTextField: UITextField!
    
    var entity: LocationEntity? {
        didSet { update() }
    }
    
    var binding:((LocationEntity)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        update()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        latTextField.delegate = self
        lonTextField.delegate = self
        latTextField.returnKeyType = .done
        lonTextField.returnKeyType = .done
        becomeFirstResponder()
        validateInput()
    }

    func validateInput() {
        if let loc = self.parsedLocation() {
            statusImageView.image = UIImage(named: "Correct")
            let updatedEntity = LocationEntity(info: entity!.info, value:loc)
            binding?(updatedEntity)
        } else {
            statusImageView.image = UIImage(named: "Incorrect")
        }
    }
    
    func parsedLocation() -> CLLocation? {
        let lat: CLLocationDegrees? = latTextField.text.flatMap{ CLLocationDegrees($0) }
        let lon: CLLocationDegrees? = lonTextField.text.flatMap{ CLLocationDegrees($0) }
        if (lat != nil && lon != nil) {
            let location = CLLocation(latitude: lat!, longitude: lon!)
            return location
        }
        return nil
    }
        
    private func update() {
        latTextField.text = entity?.value.flatMap{ "\($0.coordinate.latitude)" }
        lonTextField.text = entity?.value.flatMap{"\($0.coordinate.longitude)" }
        statusImageView.image = self.parsedLocation() != nil ? UIImage(named: "Correct") : UIImage(named: "Incorrect")
    }
}


extension LocationTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateInput()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension LocationTableViewCell: NibProvider {
    static let reuseIdentifier: String = "LocationTableViewCellReusedID"

    static var nib: UINib {
        return UINib(nibName: "LocationTableViewCell", bundle: Bundle(for: self))
    }
}

extension LocationTableViewCell: BindingView {
    typealias T = LocationEntity
}
