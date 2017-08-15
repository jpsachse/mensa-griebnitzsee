//
//  UrlBuilder.swift
//  Mensa Griebnitzsee
//
//  Copyright © 2017 Jan Philipp Sachse. All rights reserved.
//

import Foundation

open class UrlBuilder {
  
  open static func buildDaysRequestUrl() -> URL? {
    return URL(string: "http://openmensa.org/api/v2/canteens/62/days")
  }
  
  open static func buildMenuRequestUrl(for date: String) -> URL? {
    return URL(string: "http://openmensa.org/api/v2/canteens/62/days/" + date + "/meals")
  }
  
}
