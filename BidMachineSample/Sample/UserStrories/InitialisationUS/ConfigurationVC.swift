//
//  ConfigurationTableViewController.swift
//  Sample
//
//  Created by Stas Kochkin on 18/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit
import BidMachine


class ConfigurationVC: DataTableViewController {    
    override func setupSections() {
        addAppConfigurationSection()
        addUrlSection()
        addHeaderBiddingSection()
        addUserTargetingSection()
        addPublisherInfoSection()
        addLocationTargetingSection()
        addAppTargetingSection()
        addAdResttrictionsSection()
        addSdkRestrictionsSection()
    }
    
    private var configs: [BDMAdNetworkConfigEntity] = []
    
    @IBAction func clouseTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAndCloseTouched(_ sender: UIButton) {
        SdkContext.shared.synchronise()
        SdkContext.shared.configuration.networkConfigurations = configs.filter { $0.included }.compactMap { $0.config }
        dismiss(animated: true, completion: nil)
    }
    
    private func addAppConfigurationSection() {
        addSection { section in
            section.title = "App configuration"
            section.state = .expanded
            
            section
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Test mode", value:SdkContext.shared.configuration.testMode)
                    cell.binding = { SdkContext.shared.configuration.testMode = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Logging", value:SdkContext.shared.appConfiguration.logging)
                    cell.binding = { SdkContext.shared.appConfiguration.logging = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Logs on callbacks", value:SdkContext.shared.appConfiguration.callbackLog)
                    cell.binding = { SdkContext.shared.appConfiguration.callbackLog = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Location", value:SdkContext.shared.appConfiguration.location)
                    cell.binding = { SdkContext.shared.appConfiguration.location = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Toasts", value:SdkContext.shared.appConfiguration.toast)
                    cell.binding = { SdkContext.shared.appConfiguration.toast = $0.value! }
                    row.cell = cell
            }
        }
    }
    
    private func addUrlSection() {
        addSection { section in
            section.title = "Base URL"
            section.state = .collapsed
            section.addRow { row in
                let cell: DataTableViewCell = self.tableView.dequeueCell()
                cell.entity = DataEntity(info: "Init endpointh", type:.url,
                                         value: SdkContext.shared.configuration.baseURL.absoluteString)
                cell.binding = { SdkContext.shared.configuration.baseURL = $0.value.flatMap(URL.init)!  }
                row.cell = cell
            }
        }
    }
    
    private func addHeaderBiddingSection() {
        addSection { section in
            section.title = "Header Bidding"
            section.state = .expanded
            HeaderBiddingProvider.shared.getConfigEntities { entries in
                self.configs = entries
                entries.forEach { entry in
                    section.addRow { [unowned self] row in
                        let cell: OnlyLabelTableViewCell = self.tableView.dequeueCell()
                        let name = entry.config.name
                        cell.entity = OnlyLabelEntity(info: name.capitalizingFirstLetter(), value: name)
                        cell.accessoryType = .none
                        row.onSelection = {
                            cell.accessoryType.switch()
                            let index = self.configs.firstIndex { $0.config.name == name }!
                            let unit = self.configs[index]
                            self.configs.remove(at: index)
                            self.configs.insert((unit.config, cell.accessoryType.marked),
                                                at: index)
                        }
                        row.cell = cell
                    }
                }
            }
        }
    }
}
