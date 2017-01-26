//
//  Id.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper

class Ids: Mappable {

    var trakt: Int = 0
    var slug: String = ""
    var tvdb: Int = 0
    var imdb: String = ""
    var tmdb: Int = 0
    var tvrage: Int = 0

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        trakt <- map["trakt"]
        slug <- map["slug"]
        tvdb <- map["tvdb"]
        imdb <- map["imdb"]
        tmdb <- map["tmdb"]
        tvrage <- map["tvrage"]
    }
    
}
