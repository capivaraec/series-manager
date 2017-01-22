//
//  Show.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper

class Show: Mappable {

    var title: String!
    var year: Int!
    var ids: Ids!

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        title <- map["title"]
        year <- map["year"]
        ids <- map["ids"]
    }
    
}
