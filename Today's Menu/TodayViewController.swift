//
//  TodayViewController.swift
//  Today's Menu
//
//  Created by Jan Philipp Sachse on 14.08.17.
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import UIKit
import NotificationCenter
import MensaKit

class TodayViewController: UIViewController, NCWidgetProviding {
  
  let menuLoader = MenuLoader()
  var loadedMenu: Menu?
  var displayMode: NCWidgetDisplayMode = .compact
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    extensionContext?.widgetLargestAvailableDisplayMode = .expanded
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    loadedMenu = nil
  }
  
  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    let order = Calendar.current.compare(menuLoader.lastUpdatedDate, to: Date(), toGranularity: .day)
    if order == .orderedSame, menuLoader.loadMenuFromDisk() != nil, loadedMenu != nil {
      completionHandler(.noData)
      return
    }
    menuLoader.load { [unowned self] (menu) in
      self.loadedMenu = menu
      if menu == nil {
        completionHandler(NCUpdateResult.noData)
        return
      }
      DispatchQueue.main.sync { [unowned self] in
        self.reloadUI()
        completionHandler(NCUpdateResult.newData)
      }
    }
  }
  
  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    self.displayMode = activeDisplayMode
    reloadUI()
  }
  
  func reloadUI() {
    // Make the widget huge at first to allow the tableview to layout the cells
    self.preferredContentSize = CGSize(width: self.view.frame.width, height: 1000)
    self.view.frame.size = self.preferredContentSize
    self.view.layoutIfNeeded()
    self.tableView.reloadData()
    self.tableView.layoutIfNeeded()
    
    if self.displayMode == .compact {
      self.preferredContentSize = CGSize(width: self.view.frame.width, height: 110)
    } else {
      self.preferredContentSize = self.tableView.contentSize
    }
  }
  
}

extension TodayViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let loadedMenu = loadedMenu, let entry = loadedMenu.entries.first else { return 1 }
    return entry.dishes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if menuLoader.loading {
      return tableView.dequeueReusableCell(withIdentifier: "todayMenuLoadingCell", for: indexPath)
    }
    guard let entry = loadedMenu?.entries.first, entry.dishes.count > indexPath.row else {
      return tableView.dequeueReusableCell(withIdentifier: "todayMenuNoDataCell", for: indexPath)
    }
    guard !entry.closed else {
      return tableView.dequeueReusableCell(withIdentifier: "todayMenuClosedCell", for: indexPath)
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "todayMenuDishCell", for: indexPath)
    guard let menuCell = cell as? TodayMenuTableViewCell else { return cell }
    
    let dish = entry.dishes[indexPath.row]
    menuCell.notesLabel.text = dish.notes.joined(separator: ", ")
    menuCell.nameLabel.text = dish.name
    menuCell.categoryLabel.text = dish.category
    return menuCell
  }
  
}
