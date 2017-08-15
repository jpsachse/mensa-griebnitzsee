//
//  ViewController.swift
//  Mensa Griebnitzsee
//
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import UIKit
import MensaKit

class ViewController: UICollectionViewController {
  
  let menuLoader = MenuLoader()
  var loadedMenu: Menu?
  let dateFormatter = DateFormatter()
  let refreshControl = UIRefreshControl()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .none
    
    refreshControl.addTarget(self, action: #selector(updateMenu), for: .valueChanged)
    collectionView?.addSubview(refreshControl)
    
    // support dragging of entries into other apps, because why not
    collectionView?.dragDelegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.layoutIfNeeded()
    updateCollectionViewLayout()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: { [unowned self] (context) in
      self.updateCollectionViewLayout()
    }) { (context) in }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    refreshControl.beginRefreshing()
    updateMenu()
  }
  
  @objc func updateMenu() {
    loadedMenu = nil
    collectionView?.reloadData()
    menuLoader.load { [unowned self] (menu) in
      self.loadedMenu = menu
      DispatchQueue.main.async { [unowned self] in
        self.collectionView?.reloadData()
        self.refreshControl.endRefreshing()
      }
    }
  }

  func updateCollectionViewLayout() {
    if UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass == .regular {
      collectionView?.collectionViewLayout = getColumnLayout()
    } else {
      collectionView?.collectionViewLayout = getRowLayout()
    }
  }
  
  func getCommonLayout(with padding: CGFloat) -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 10
    layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding)
    layout.headerReferenceSize = CGSize(width: collectionView!.frame.width, height: 40)
    return layout
  }
  
  func getRowLayout() -> UICollectionViewFlowLayout {
    let defaultPadding: CGFloat = 10
    let rowLayout = getCommonLayout(with: defaultPadding)
    rowLayout.itemSize = CGSize(width: collectionView!.frame.width - 2 * defaultPadding, height: 100)
    return rowLayout
  }
  
  func getColumnLayout() -> UICollectionViewFlowLayout {
    let defaultPadding: CGFloat = 10
    let rowLayout = getCommonLayout(with: defaultPadding)
    rowLayout.itemSize = CGSize(width: collectionView!.frame.width / 2 - 1.5 * defaultPadding, height: 150)
    return rowLayout
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    if let loadedMenu = loadedMenu {
      return loadedMenu.entries.count
    }
    return 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let loadedMenu = loadedMenu {
      let entry = loadedMenu.entries[section]
      if entry.closed {
        return 1
      }
      return loadedMenu.entries[section].dishes.count
    }
    return 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let loadedMenu = loadedMenu, indexPath.section < loadedMenu.entries.count else {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
    }
    let entry = loadedMenu.entries[indexPath.section]
    var cell: UICollectionViewCell!
    if entry.closed {
      cell = collectionView.dequeueReusableCell(withReuseIdentifier: "closedCell", for: indexPath)
    } else {
      cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath)
      if let cell = cell as? MenuCollectionViewCell, indexPath.row < entry.dishes.count {
        let dish = entry.dishes[indexPath.row]
        cell.categoryLabel.text = dish.category
        cell.dishNameLabel.text = dish.name
        cell.notesLabel.text = dish.notes.joined(separator: ", ")
      }
    }
    cell.layer.cornerRadius = 10
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                               withReuseIdentifier: "sectionHeader",
                                                               for: indexPath)
    if let view = view as? MenuHeaderCollectionReusableView, let loadedMenu = loadedMenu {
      let dateString = dateFormatter.string(from: loadedMenu.entries[indexPath.section].date)
      view.label.text = dateString
    }
    return view
  }
  
}

extension ViewController: UICollectionViewDragDelegate {
  
  func getDragItems(for indexPath: IndexPath) -> [UIDragItem] {
    guard let loadedMenu = loadedMenu, indexPath.section < loadedMenu.entries.count,
      indexPath.row < loadedMenu.entries[indexPath.section].dishes.count else { return [] }
    let dish = loadedMenu.entries[indexPath.section].dishes[indexPath.row]
    let provider = NSItemProvider(object: dish.description as NSString)
    let item = UIDragItem(itemProvider: provider)
    return [item]
  }
  
  func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession,
                      at indexPath: IndexPath) -> [UIDragItem] {
    return getDragItems(for: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession,
                      at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
    return getDragItems(for: indexPath)
  }
  
}
