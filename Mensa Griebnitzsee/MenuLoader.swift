//
//  MenuLoader.swift
//  Mensa Griebnitzsee
//
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import Foundation

typealias MenuLoadCompletionHandler = (Menu?) -> ()

class MenuLoader {
    
  func load(completionHandler: @escaping MenuLoadCompletionHandler) {
    guard let daysUrl = UrlBuilder.buildDaysRequestUrl() else {
      completionHandler(nil)
      return
    }
    let daysRequest = URLRequest(url: daysUrl)
    let session = URLSession(configuration: .default)
    let daysTask = session.dataTask(with: daysRequest) { (data, response, error) in
      guard let data = data else {
        completionHandler(nil)
        return
      }
      let menu = Menu()
      do {
        let daysObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let days = daysObject as? [[String:Any]] else {
          completionHandler(nil)
          return
        }
        var loadedDays = 0
        for var day in days {
          guard let dayString = day["date"] as? String,
              let closed = day["closed"] as? Bool,
              let mealsUrl = UrlBuilder.buildMenuRequestUrl(for: dayString) else {
            completionHandler(nil)
            return
          }
          let mealsTask = session.dataTask(with: mealsUrl) { (data, response, error) in
            menu.addEntry(loadedData: data, at: dayString, closed: closed)
            loadedDays += 1
            if loadedDays == days.count {
              menu.entries.sort(by: { (first, second) -> Bool in
                return first.date < second.date                
              })
              completionHandler(menu)
            }
          }
          mealsTask.resume()
        }
      } catch {
        completionHandler(nil)
      }
    }
    daysTask.resume()
  }
    
}
