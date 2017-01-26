//
//  Configuration.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import Locksmith
import AwesomeCache

final class Configuration: Any {

    private static let userAccount = "SeriesManagerAccount"
    private static let cacheKey = "SeriesManagerCache"

    static func getAccessToken() -> String? {
        let dict = Locksmith.loadDataForUserAccount(userAccount: userAccount)
        return dict?["access_token"] as? String
    }

    static func saveAuthorization(_ authDict: [String : Any]) {
        try? Locksmith.updateData(data: authDict, forUserAccount: userAccount)
    }

    static func revokeAuthorization() {
        try? Locksmith.deleteDataForUserAccount(userAccount: userAccount)
    }
    
    static func getRequestsCache() -> Cache<NSString>? {
        return try? Cache<NSString>(name: cacheKey)
    }
    
    static func deleteCache() {
        getRequestsCache()?.removeAllObjects()
    }
}

final class Util: Any {
    
    static func formatDate(_ strDate: String, dateStyle: DateFormatter.Style = .long, timeStyle: DateFormatter.Style = .medium) -> String {
        return stringFromDate(dateFromString(strDate), dateStyle: dateStyle, timeStyle: timeStyle)
    }

    static func stringFromDate(_ date: Date, dateStyle: DateFormatter.Style = .long, timeStyle: DateFormatter.Style = .medium) -> String {

        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle

        return formatter.string(from: date)
    }
    
    static func dateFromString(_ strDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: strDate)!
    }
    
    static func minutesToDaysHoursMinutes(_ minutes: Int) -> (days: Int, hours: Int, minutes: Int) {
        return (minutes / 1440, (minutes % 1440) / 24, (minutes % 1440) % 24)
    }
}//84, 2, 31

final class Constants: Any {
    
    static let requestsCacheTTL: TimeInterval = 60 * 5 // 5 minutes
}
