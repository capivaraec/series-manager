//
//  WatchedShow.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 23/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper

class WatchedShow: Mappable {

    var aired: Int!
    var completed: Int!
    var watchedPercentage: Int!
    var show: Show!

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        self.completed <- map["completed"]
        self.aired <- map["aired"]
        self.show <- map["show"]
    }

    func setProgress(completed: Int, aired: Int) {
        self.completed = completed
        self.aired = aired
        self.watchedPercentage = completed * 100 / aired
    }
    
}
