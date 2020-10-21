//
//  StatusVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/6/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import CoreLocation


class StatusVC: DataTableViewController {
    var adStatus:(loaded: Bool, canShow:Bool)?
    override func setupSections() {
        addStatusSection()
        if let location = SdkContext.shared.currentLocation {
            addLocationSection(location)
        }
    }
    
    private func addStatusSection() {
        addSection { section in
            section.title = "Ad status"
            section.state = .expanded
            section
                .addRow {
                    [unowned self] row in
                    let cell: StatusTableViewCell = self.tableView.dequeueCell()
                    cell.entity = StatusEntity(info: "Ad was loaded", value:self.adStatus?.loaded)
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: StatusTableViewCell = self.tableView.dequeueCell()
                    cell.entity = StatusEntity(info: "Ad can be shown", value:self.adStatus?.canShow)
                    row.cell = cell
            }
        }
    }
    
    private func addLocationSection(_ location:CLLocation) {
        addSection { section in
            section.title = "User location"
            section.state = .collapsed
            section
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Latitude", type:.string, value:"\(location.coordinate.latitude)")
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Longitude", type:.string, value:"\(location.coordinate.longitude)")
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Accuracy", type:.string, value:"\(location.horizontalAccuracy)")
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Timestamp", type:.string, value:"\(location.timestamp)")
                    row.cell = cell
            }
        }
    }
}
