//
//  Configuration.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import Locksmith

final class Configuration: NSObject {

    private static let userAccount = "SeriesManagerAccount"

    class func getAccessToken() -> String? {
        let dict = Locksmith.loadDataForUserAccount(userAccount: userAccount)
        return dict?["access_token"] as? String
    }

    class func saveAuthorization(_ authDict: [String : Any]) {
        try? Locksmith.updateData(data: authDict, forUserAccount: userAccount)
    }

    class func revokeAuthorization() {
        try? Locksmith.deleteDataForUserAccount(userAccount: userAccount)
    }
}
