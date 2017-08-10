//
//  UrlBuilder.swift
//  Mensa Griebnitzsee
//
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import Foundation

class UrlBuilder {
  
  static func buildDaysRequestUrl() -> URL? {
    return URL(string: "http://openmensa.org/api/v2/canteens/62/days")
  }
  
  static func buildMenuRequestUrl(for date: String) -> URL? {
    return URL(string: "http://openmensa.org/api/v2/canteens/62/days/" + date + "/meals")
  }
  
}
