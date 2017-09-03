//
//  MenuLoader.swift
//  Mensa Griebnitzsee
//
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import Foundation

public typealias MenuLoadCompletionHandler = (Menu?) -> ()

public class MenuLoader {
  
  public private(set) var loading = false
  private let userDefaults = UserDefaults(suiteName: "group.de.jps.mensa-griebnitzsee")
  public var lastUpdatedDate: Date {
    get {
      return userDefaults?.object(forKey: "lastUpdateTime") as? Date ?? Date(timeIntervalSince1970: 0)
    }
    set {
      userDefaults?.set(newValue, forKey: "lastUpdateTime")
    }
  }
  
  public init() {}

  public func load(completionHandler: @escaping MenuLoadCompletionHandler) {
    loading = true
    let complete = { [unowned self] (menu: Menu?) -> () in
      self.loading = false
      completionHandler(menu)
    }
    guard let daysUrl = UrlBuilder.buildDaysRequestUrl() else {
      complete(nil)
      return
    }
    let daysRequest = URLRequest(url: daysUrl)
    let session = URLSession(configuration: .default)
    let daysTask = session.dataTask(with: daysRequest) { [unowned self] (data, response, error) in
      guard let data = data else {
        complete(nil)
        return
      }
      let menu = Menu()
      do {
        let daysObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let days = daysObject as? [[String:Any]] else {
          complete(nil)
          return
        }
        var loadedDays = 0
        for var day in days {
          guard let dayString = day["date"] as? String,
              let closed = day["closed"] as? Bool,
              let mealsUrl = UrlBuilder.buildMenuRequestUrl(for: dayString) else {
            complete(nil)
            return
          }
          let mealsTask = session.dataTask(with: mealsUrl) { (data, response, error) in
            menu.addEntry(loadedData: data, at: dayString, closed: closed)
            loadedDays += 1
            if loadedDays == days.count {
              menu.entries.sort(by: { (first, second) -> Bool in
                return first.date < second.date
              })
              self.lastUpdatedDate = Date()
              self.store(menu)
              complete(menu)
            }
          }
          mealsTask.resume()
        }
      } catch {
        complete(nil)
      }
    }
    daysTask.resume()
  }
  
  private func store(_ menu: Menu) {
    let encodedData = NSKeyedArchiver.archivedData(withRootObject: menu)
    userDefaults?.set(encodedData, forKey: "loadedMenu")
  }
  
  public func loadMenuFromDisk() -> Menu? {
    guard let menuData = userDefaults?.data(forKey: "loadedMenu"),
        let menu = NSKeyedUnarchiver.unarchiveObject(with: menuData) as? Menu else {
      return nil
    }
    return menu
  }
    
}
