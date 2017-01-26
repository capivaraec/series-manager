//
//  User.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 26/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var name: String!
    var avatarUrl: String!
    var watchedShows: Int!
    var watchedEpisodes: Int!
    var duration: Int!
    var slugId: String!
    var memberSince: String!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        name <- map["user.name"]
        avatarUrl <- map["user.images.avatar.full"]
        slugId <- map["user.ids.slug"]
        memberSince <- map["user.joined_at"]
        watchedShows <- map["shows.watched"]
        watchedEpisodes <- map["episodes.watched"]
        duration <- map["episodes.minutes"]
    }
    
    func setUserStats(watchedShows: Int, watchedEpisodes: Int, duration: Int) {
        self.watchedShows = watchedShows
        self.watchedEpisodes = watchedEpisodes
        self.duration = duration
    }
}
