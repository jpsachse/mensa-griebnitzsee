//
//  Menu.swift
//  Mensa Griebnitzsee
//
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import Foundation

struct MenuDish {
  let name: String
  let category: String
  let notes: [String]
  
  var description: String {
    get {
      return category + ": " + name + " (" + notes.joined(separator: ", ") + ")"
    }
  }
}

struct MenuEntry {
  let date: Date
  let closed: Bool
  let dishes: [MenuDish]
}

class Menu {
  
  var entries: [MenuEntry] = []
  private let dateFormatter = DateFormatter()
  
  init() {
    dateFormatter.dateFormat = "yyyy-MM-dd"
  }
  
  func addEntry(loadedData: Data?, at date: String, closed: Bool) {
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
