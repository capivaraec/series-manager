//
//  Show.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper

class Calendar: Mappable {

    var firstAired: Date!
    var episode: Episode!
    var show: Show!

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        var strDate = ""
        strDate <- map["first_aired"]
        firstAired = convertDate(strDate)

        episode <- map["episode"]
        show <- map["show"]
    }

    private func convertDate(_ strDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        return dateFormatter.date(from: strDate)!
    }

}
