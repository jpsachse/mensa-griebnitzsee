//
//  Menu.swift
//  Mensa Griebnitzsee
//
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import Foundation

public struct MenuDish {
  public let name: String
  public let category: String
  public let notes: [String]
  
  public var description: String {
    get {
      return category + ": " + name + " (" + notes.joined(separator: ", ") + ")"
    }
  }
}

public struct MenuEntry {
  public let date: Date
  public let closed: Bool
  public let dishes: [MenuDish]
}

public class Menu {
  
  public var entries: [MenuEntry] = []
  private let dateFormatter = DateFormatter()
  
  public init() {
    dateFormatter.dateFormat = "yyyy-MM-dd"
  }
  
  public func addEntry(loadedData: Data?, at date: String, closed: Bool) {
    guard let date = dateFormatter.date(from: date) else {
      return
    }
    var dishes: [MenuDish] = []
      if let dishData = loadedData {
        do {
          let dishObject = try JSONSerialization.jsonObject(with: dishData, options: .allowFragments)
          if let dishInfos = dishObject as? [[String:Any]] {
            for dishInfo in dishInfos {
              if var name = dishInfo["name"] as? String, let category = dishInfo["category"] as? String,
                  let notes = dishInfo["notes"] as? [String] {
                do {
                  let regex = try NSRegularExpression(pattern: "\\s+", options: [])
                  name = regex.stringByReplacingMatches(in: name,
                                                        options: [],
                                                        range: NSMakeRange(0, name.count),
                                                        withTemplate: " ")
                } catch {}
                let dish = MenuDish(name: name, category: category, notes: notes)
                dishes.append(dish)
              }
            }
          }
        } catch {}
    }
    let entry = MenuEntry(date: date, closed: closed, dishes: dishes)
    entries.append(entry)
  }
  
}
