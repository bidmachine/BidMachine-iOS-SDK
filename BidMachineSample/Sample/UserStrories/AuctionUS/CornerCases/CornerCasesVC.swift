//
//  CornerCasesVC.swift
//  Sample
//
//  Created by Yaroslav Skachkov on 12/19/18.
//  Copyright © 2018 Yaroslav Skachkov. All rights reserved.
//

import UIKit

class CornerCasesVC: DataTableViewController {
    override func setupSections() {
        addStatusSection()
    }
    
    private func addStatusSection() {
        let _ = addSection { section in
            section.title = "Corner cases"
            section.state = .expanded
            
            let _ = section
                .addRow { [unowned self] row in
                    let cell: OnlyLabelTableViewCell = self.tableView.dequeueCell()
                    cell.entity = OnlyLabelEntity(info: "Ad's overlay", value: nil)
                    row.onSelection = { [unowned self] in
                        let overlayVC: OverlayVC? = UIApplication.shared.cornerCasesStoryboard.instantiateVC()
                        self.navigationController?.pushViewController(overlayVC!, animated: true)
                    }
                    row.cell = cell
                }
                .addRow { [unowned self] row in
                    let cell: OnlyLabelTableViewCell = self.tableView.dequeueCell()
                    cell.entity = OnlyLabelEntity(info: "Ad's visibility (scroll view inside)", value: nil)
                    row.onSelection = { [unowned self] in
                        let visibilityVC: VisibilityVC? = UIApplication.shared.cornerCasesStoryboard.instantiateVC()
                        self.navigationController?.pushViewController(visibilityVC!, animated: true)
                    }
                    row.cell = cell
                }
                .addRow { [unowned self] row in
                    let cell: OnlyLabelTableViewCell = self.tableView.dequeueCell()
                    cell.entity = OnlyLabelEntity(info: "Banner overlayed by ad", value: nil)
                    row.onSelection = { [unowned self] in
                        let bannerOverlayVC: BannerOverlayVC? = UIApplication.shared.cornerCasesStoryboard.instantiateVC()
                        self.navigationController?.pushViewController(bannerOverlayVC!, animated: true)
                    }
                    row.cell = cell
                }
                .addRow { [unowned self] row in
                    let cell: OnlyLabelTableViewCell = self.tableView.dequeueCell()
                    cell.entity = OnlyLabelEntity(info: "Turn on banner", value: nil)
                    row.onSelection = { [unowned self] in
                        let bannerLoadingVC: BannerLoadingVC? = UIApplication.shared.cornerCasesStoryboard.instantiateVC()
                        self.navigationController?.pushViewController(bannerLoadingVC!, animated: true)
                    }
                    row.cell = cell
                }
        }
    }
}
