//
//  DataTableViewController.swift
//  Sample
//
//  Created by Stas Kochkin on 19/11/2018.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit


class Row {
    let height: CGFloat = 44.0
    var cell: UITableViewCell?
    var onSelection:(()->())?
    fileprivate var configure:((Row)->())?
}


class Section {
    let headerViewHeight: CGFloat = 25.0
    fileprivate var configure:((Section)->())?
    
    enum State {
        case collapsed
        case expanded
        mutating func change() {
            self = self == .collapsed ? .expanded : .collapsed
        }
    }
    
    var title: String = ""
    var state: State = .collapsed
    var rows: [Row?] = []
    
    @discardableResult
    func addRow(_ configure:@escaping (Row)->()) -> Section {
        let row = Row()
        row.configure = configure
        row.configure?(row)
        rows.append(row)
        return self
    }
}


class DataTableViewController: UITableViewController {
    private var sections: [Section?] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSections()
    }
    
    private func setupTableView() {
        tableView.register(EnumTableViewCell.nib, forCellReuseIdentifier: EnumTableViewCell.reuseIdentifier)
        tableView.register(KeyValuePairTableViewCell.nib, forCellReuseIdentifier: KeyValuePairTableViewCell.reuseIdentifier)
        tableView.register(DataTableViewCell.nib, forCellReuseIdentifier: DataTableViewCell.reuseIdentifier)
        tableView.register(BooleanTableViewCell.nib, forCellReuseIdentifier: BooleanTableViewCell.reuseIdentifier)
        tableView.register(LocationTableViewCell.nib, forCellReuseIdentifier: LocationTableViewCell.reuseIdentifier)
        tableView.register(StatusTableViewCell.nib, forCellReuseIdentifier: StatusTableViewCell.reuseIdentifier)
        tableView.register(GeneratableDataTableViewCell.nib, forCellReuseIdentifier: GeneratableDataTableViewCell.reuseIdentifier)
        tableView.register(OnlyLabelTableViewCell.nib, forCellReuseIdentifier: OnlyLabelTableViewCell.reuseIdentifier)
    }
    
    @discardableResult
    final func addSection(_ configure:@escaping (Section)->()) -> DataTableViewController {
        let sec = Section()
        sec.configure = configure
        sec.configure?(sec)
        sections.append(sec)
        return self
    }
    
    @discardableResult
    final func insertSection(_ index: Int ,_ configure:@escaping (Section)->()) -> DataTableViewController {
        let sec = Section()
        sec.configure = configure
        sec.configure?(sec)
        tableView.beginUpdates()
        sections.insert(sec, at:index)
        tableView.insertSections([index], with: .automatic)
        tableView.endUpdates()
        return self
    }
    
    final func removeSection(_ title:String) -> Int {
        let idx = sections.compactMap{ $0?.title }.firstIndex(of: title)!
        tableView.beginUpdates()
        sections.remove(at: idx)
        tableView.deleteSections([idx], with: .automatic)
        tableView.endUpdates()
        return idx
    }
    
    open func setupSections() {}
}


extension DataTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = sections[section], section.state != .collapsed else {  return 0 }
        return section.rows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section]!.rows[indexPath.row]!.height
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section]!.headerViewHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView.nib.instantiate(withOwner: self, options: nil).first as! HeaderView
        headerView.section = sections[section]
        headerView.onUserInteract = { [weak self] in
            self?.sections[section]?.state.change()
            headerView.animate()
            self?.tableView.reloadSections(IndexSet([section]), with: .automatic)
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section]!.rows[indexPath.row]!.cell ?? UITableViewCell.init(style: .default, reuseIdentifier: nil)
    }
}


extension DataTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = self.sections[indexPath.section]?.rows[indexPath.row]
        row?.onSelection?()
    }
}


extension UITableView {
    func dequeueCell<T:NibProvider>() -> T {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier) as! T
    }
}


extension DataTableViewController {
    func addUserTargetingSection() {
        addSection { section in
            section.title = "User targeting"
            section
                .addRow {
                    [unowned self] row in
                    let cell: GeneratableDataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "User ID", type:.string, value: SdkContext.shared.targeting.userId)
                    cell.generate = { entity, closure in closure( DataEntity(info: "User ID", type:.string, value: UUID().uuidString) ) }
                    cell.binding = { SdkContext.shared.targeting.userId = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Year of birth", type:.numeric, value: SdkContext.shared.targeting.yearOfBirth.stringValue)
                    cell.binding = { SdkContext.shared.targeting.yearOfBirth = NSNumber(integerLiteral: $0.value.flatMap{Int($0)} ?? 0) }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: EnumTableViewCell = self.tableView.dequeueCell()
                    cell.entity = StringEnumEntity(info: "Gender", value: SdkContext.shared.targeting.gender, possibleValues: ["F", "M", "O"])
                    cell.binding = { SdkContext.shared.targeting.gender = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Keywords", type: .commaSeparatedList, value: SdkContext.shared.targeting.keywords)
                    cell.binding = { SdkContext.shared.targeting.keywords = $0.value! }
                    row.cell = cell
            }
        }
    }
    
    func addPublisherInfoSection() {
        addSection { section in
            section.title = "Publisher Info"
            section
                .addRow {
                    [unowned self] row in
                    let cell: GeneratableDataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Publisher ID", type:.string, value: SdkContext.shared.publisherInfo.publisherId)
                    cell.generate = { entity, closure in closure( DataEntity(info: "Publisher ID", type:.string, value: UUID().uuidString) ) }
                    cell.binding = { SdkContext.shared.publisherInfo.publisherId = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: GeneratableDataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Publisher Name", type:.string, value: SdkContext.shared.publisherInfo.publisherName)
                    cell.generate = { entity, closure in closure( DataEntity(info: "Publisher Name", type:.string, value: UUID().uuidString) ) }
                    cell.binding = { SdkContext.shared.publisherInfo.publisherName = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: GeneratableDataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Publisher Domain", type:.string, value: SdkContext.shared.publisherInfo.publisherDomain)
                    cell.generate = { entity, closure in closure( DataEntity(info: "Publisher Domain", type:.string, value: UUID().uuidString) ) }
                    cell.binding = { SdkContext.shared.publisherInfo.publisherDomain = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Publisher categories", type: .commaSeparatedList, value:SdkContext.shared.publisherInfo.publisherCategories?.joined(separator: ", "))
                    cell.binding = { SdkContext.shared.publisherInfo.publisherCategories = $0.value!.commaSeparatedList()}
                    row.cell = cell
            }
        }
    }
    
    func addLocationTargetingSection() {
        addSection { section in
            section.title = "Location targeting"
            section
                .addRow {
                    [unowned self] row in
                    let cell: LocationTableViewCell = self.tableView.dequeueCell()
                    cell.entity = LocationEntity(info: "Coordinates", value: SdkContext.shared.targeting.deviceLocation)
                    cell.binding = { SdkContext.shared.targeting.deviceLocation = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Country", type:.string, value: SdkContext.shared.targeting.country)
                    cell.binding = { SdkContext.shared.targeting.country = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "City", type:.string, value: SdkContext.shared.targeting.city)
                    cell.binding = { SdkContext.shared.targeting.city = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Postal code", type:.string, value: SdkContext.shared.targeting.zip)
                    cell.binding = { SdkContext.shared.targeting.zip = $0.value! }
                    row.cell = cell
            }
        }
    }
    
    func addAppTargetingSection() {
        addSection { [unowned self] section in
            section.title = "Application targeting"
            section
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Store ID", type: .numeric, value:SdkContext.shared.targeting.storeId)
                    cell.binding = { SdkContext.shared.targeting.storeId = $0.value }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Store URL", type: .url, value:SdkContext.shared.targeting.storeURL?.absoluteString)
                    cell.binding = { SdkContext.shared.targeting.storeURL = URL(string:$0.value!) }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Paid", value: SdkContext.shared.targeting.paid)
                    cell.binding = { SdkContext.shared.targeting.paid = $0.value! }
                    row.cell = cell
            }
        }
    }
    
    func addAdResttrictionsSection() {
        addSection { section in
            section.title = "Ad restrictions"
            section
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Blocked apps", type: .commaSeparatedList, value:SdkContext.shared.targeting.blockedApps?.joined(separator: ", "))
                    cell.binding = { SdkContext.shared.targeting.blockedApps = $0.value!.commaSeparatedList()}
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Blocked categories", type: .commaSeparatedList, value:SdkContext.shared.targeting.blockedCategories?.joined(separator: ", "))
                    cell.binding = { SdkContext.shared.targeting.blockedCategories = $0.value!.commaSeparatedList()}
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: DataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Blocked advertisers", type: .commaSeparatedList, value:SdkContext.shared.targeting.blockedAdvertisers?.joined(separator: ", "))
                    cell.binding = { SdkContext.shared.targeting.blockedAdvertisers = $0.value!.commaSeparatedList()}
                    row.cell = cell
            }
        }
    }
    
    func addSdkRestrictionsSection() {
        addSection { section in
            section.title = "User restrictions"
            section
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "COPPA", value:SdkContext.shared.restriction.coppa)
                    cell.binding = { SdkContext.shared.restriction.coppa = $0.value! }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    // SDK API
//                    cell.entity = BooleanEntity(info: "Subject to GDPR", value: SdkContext.shared.restriction.subjectToGDPR)
//                    cell.binding = { SdkContext.shared.restriction.subjectToGDPR = $0.value! }
                    // User Defaults
                    cell.entity = BooleanEntity(info: "Subject to GDPR", value: UserDefaults.standard.string(forKey: "IABConsent_SubjectToGDPR") == "1")
                    cell.binding = { UserDefaults.standard.set($0.value! ? "1" : "0", forKey: "IABConsent_SubjectToGDPR") }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: GeneratableDataTableViewCell = self.tableView.dequeueCell()
                    cell.entity = DataEntity(info: "Consent string", type:.string, value: SdkContext.shared.restriction.consentString)
                    // SDK API
//                    cell.generate = { entity, closure in closure( DataEntity(info: "Consent string", type: .string, value: SdkContext.shared.consentString)) }
//                    cell.binding = { SdkContext.shared.restriction.consentString = $0.value! }
                    // User Defaults
                    cell.generate = { entity, closure in closure( DataEntity(info: "Consent string", type: .string, value: UserDefaults.standard.string(forKey: "IABConsent_ConsentString"))) }
                    cell.binding = { UserDefaults.standard.set($0.value, forKey: "IABConsent_ConsentString") }
                    row.cell = cell
                }
                .addRow {
                    [unowned self] row in
                    let cell: BooleanTableViewCell = self.tableView.dequeueCell()
                    cell.entity = BooleanEntity(info: "Consent", value: SdkContext.shared.restriction.hasConsent)
                    cell.binding = { SdkContext.shared.restriction.hasConsent = $0.value! }
                    row.cell = cell
            }
        }
    }
}

