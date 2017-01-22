//
//  Episode.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper

class Episode: Mappable {

    var season: Int!
    var number: Int!
    var title: String!
    var ids: Ids!

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        season <- map["season"]
        number <- map["number"]
        title <- map["title"]
        ids <- map["ids"]
    }
    
}
