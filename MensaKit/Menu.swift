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

public class Menu: NSObject, NSCoding {
  
  public var entries: [MenuEntry] = []
  private let dateFormatter = DateFormatter()
  
  public override init() {
    super.init()
    dateFormatter.dateFormat = "yyyy-MM-dd"
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(entries.count, forKey: "numberOfEntries")
    for entryIndex in 0..<entries.count {
      let entry = entries[entryIndex]
      aCoder.encode(entry.date, forKey: "entry\(entryIndex)Date")
      aCoder.encode(entry.closed, forKey: "entry\(entryIndex)Closed")
      aCoder.encode(entry.dishes.count, forKey: "entry\(entryIndex)NumberOfDishes")
      for dishIndex in 0..<entry.dishes.count {
        let dish = entry.dishes[dishIndex]
        aCoder.encode(dish.name, forKey: "entry\(entryIndex)Dish\(dishIndex)Name")
        aCoder.encode(dish.category, forKey: "entry\(entryIndex)Dish\(dishIndex)Category")
        aCoder.encode(dish.notes.count, forKey: "entry\(entryIndex)Dish\(dishIndex)NumberOfNotes")
        for noteIndex in 0..<dish.notes.count {
          let note = dish.notes[noteIndex]
          aCoder.encode(note, forKey: "entry\(entryIndex)Dish\(dishIndex)Note\(noteIndex)")
        }
      }
    }
  }
  
  public required convenience init?(coder aDecoder: NSCoder) {
    self.init()
    let numberOfEntries = aDecoder.decodeInteger(forKey: "numberOfEntries")
    for entryIndex in 0..<numberOfEntries {
      guard let date = aDecoder.decodeObject(forKey: "entry\(entryIndex)Date") as? Date else { break }
      let closed = aDecoder.decodeBool(forKey: "entry\(entryIndex)Closed")
      let numberOfDishes = aDecoder.decodeInteger(forKey: "entry\(entryIndex)NumberOfDishes")
      var dishes: [MenuDish] = []
      for dishIndex in 0..<numberOfDishes {
        let nameKey = "entry\(entryIndex)Dish\(dishIndex)Name"
        let categoryKey = "entry\(entryIndex)Dish\(dishIndex)Category"
        let numberOfNotesKey = "entry\(entryIndex)Dish\(dishIndex)NumberOfNotes"
        let numberOfNotes = aDecoder.decodeInteger(forKey: numberOfNotesKey)
        guard let name = aDecoder.decodeObject(forKey: nameKey) as? String,
            let category = aDecoder.decodeObject(forKey: categoryKey) as? String else {
          break
        }
        var notes: [String] = []
        for noteIndex in 0..<numberOfNotes {
          let noteKey = "entry\(entryIndex)Dish\(dishIndex)Note\(noteIndex)"
          if let note = aDecoder.decodeObject(forKey: noteKey) as? String {
            notes.append(note)
          }
        }
        dishes.append(MenuDish(name: name, category: category, notes: notes))
      }
      entries.append(MenuEntry(date: date, closed: closed, dishes: dishes))
    }
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
