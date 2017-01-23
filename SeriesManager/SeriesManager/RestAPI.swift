//
//  RestAPI.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper

final class RestAPI {

    private static let clientID = "f36eefe52b427fd2ed0fb2605fa3f938e2685c49785ddb00c4a2701c375bc2bc"
    private static let clientSecret = "7e0fafe81508bf8d16c3624f6b989f65196ebf3ddfef23ecba729e9584bfeabd"
    private static let authorizationEndPoint = "https://trakt.tv/oauth/authorize"
    private static let accessTokenEndPoint = "https://trakt.tv/oauth/token"
    private static let redirectURI = "https://com.capivaraec.seriesmanager/callback"

    static func getAuthorizationRequest() -> URLRequest {

        let responseType = "code"
        let state = "state\(Date().timeIntervalSince1970)"

        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(clientID)&"
        authorizationURL += "redirect_uri=\(redirectURI.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)&"
        authorizationURL += "state=\(state)"

        return URLRequest(url: URL(string: authorizationURL)!)
    }

    static func requestForAccessToken(authorizationCode: String, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let grantType = "authorization_code"

        let postParams = ["grant_type" : grantType,
                          "code" : authorizationCode,
                          "redirect_uri" : redirectURI,
                          "client_id" : clientID,
                          "client_secret" : clientSecret]

        let json = try! JSONSerialization.data(withJSONObject: postParams)
        var request = URLRequest(url: URL(string: accessTokenEndPoint)!)

        request.httpMethod = "POST"
        request.httpBody = json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in

            let statusCode = (response as! HTTPURLResponse).statusCode

            if statusCode == 200 {

                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]

                    Configuration.saveAuthorization(dataDictionary)

                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                } catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }
        }
        
        task.resume()
    }
//Get Watched
    // Get show watched progress (para pegar o progresso) -> https://api.trakt.tv/shows/hannibal/progress/watched

    static private func addRequestHeaders(_ request: URLRequest) -> URLRequest {
        var newRequest = request
        let accessToken = Configuration.getAccessToken()!
// a1c90b5a53fa2659dfe91d62fd4be0cc1cc62169a9a1a1decbb209efd22a5e77
        newRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        newRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        newRequest.addValue("2", forHTTPHeaderField: "trakt-api-version")
        newRequest.addValue("f36eefe52b427fd2ed0fb2605fa3f938e2685c49785ddb00c4a2701c375bc2bc", forHTTPHeaderField: "trakt-api-key")

        return newRequest
    }

    static func getWatchedShows(result: @escaping (_ shows: [WatchedShow]?) -> Void) {

        let targetURLString = "https://api.trakt.tv/sync/watched/shows"
        var request = URLRequest(url: URL(string: targetURLString)!)

        request.httpMethod = "GET"
        request = addRequestHeaders(request)

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in

            let statusCode = (response as! HTTPURLResponse).statusCode

            if statusCode == 200 {

                let mapper = Mapper<WatchedShow>()
                guard let watchedShows = mapper.mapArray(JSONString: String(data: data!, encoding: .utf8)!) else {
                    result(nil)
                    return
                }

                let semaphore = DispatchSemaphore(value: 0)
                _ = semaphore.wait(timeout: .distantFuture)
                for watchedShow in watchedShows {
                    getWatchedProgress(watchedShow: watchedShow, result: { (watchedShowWithProgress) in
                        result(watchedShows)
                    })
                }
            }
        }
        
        task.resume()
    }

    private static func getWatchedProgress(watchedShow: WatchedShow, result: @escaping (_ whatchedShow: WatchedShow) -> Void) {

        let targetURLString = "https://api.trakt.tv/shows/\(watchedShow.show.ids.slug)/progress/watched"
        var request = URLRequest(url: URL(string: targetURLString)!)

        request.httpMethod = "GET"
        request = addRequestHeaders(request)

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in

            let statusCode = (response as! HTTPURLResponse).statusCode

            if statusCode == 200 {

                let mapper = Mapper<WatchedShow>()
                guard let showProgress = mapper.map(JSONString: String(data: data!, encoding: .utf8)!) else {
                    result(watchedShow)
                    return
                }

                watchedShow.setProgress(completed: showProgress.completed, aired: showProgress.aired)
                result(watchedShow)
            }
        }
        
        task.resume()

    }

    // Get a single show -> https://api.trakt.tv/shows/hannibal?extended=full mosstrar os detalhes de cada série (ou detalhes de cada episódio?)

}
