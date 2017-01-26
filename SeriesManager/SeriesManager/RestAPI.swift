//
//  RestAPI.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 22/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift
import AwesomeCache

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

    static private func addRequestHeaders(_ request: URLRequest) -> URLRequest {
        var newRequest = request
        let accessToken = Configuration.getAccessToken()!

        newRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        newRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        newRequest.addValue("2", forHTTPHeaderField: "trakt-api-version")
        newRequest.addValue(clientID, forHTTPHeaderField: "trakt-api-key")

        return newRequest
    }
    
    static func revokeToken(completion: @escaping (_ success: Bool) -> Void) {
        
        guard let accessToken = Configuration.getAccessToken() else {
            DispatchQueue.main.async {
                completion(true)
            }
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.trakt.tv/oauth/revoke")!)
        
        let postParams = ["token" : accessToken]
        
        let json = try! JSONSerialization.data(withJSONObject: postParams)
        
        request.httpBody = json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request = addRequestHeaders(request)
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            DispatchQueue.main.async {
                completion(statusCode == 200)
            }
        }
        
        task.resume()
    }
    
    static func getUserInformation() -> Observable<User?> {
        return Observable<User?>.create { observer in
            self.getUserSettings(result: { settings in
                
                if settings != nil {
                    if let userStats = getUserStats(userId: settings!.slugId) {
                        settings!.setUserStats(watchedShows: userStats.watchedShows, watchedEpisodes: userStats.watchedEpisodes, duration: userStats.duration)
                    }
                }
                
                observer.onNext(settings)
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
    
    private static func getUserSettings(result: @escaping (_ user: User?) -> Void) {
        
        let targetURLString = "https://api.trakt.tv/users/settings"
        var request = URLRequest(url: URL(string: targetURLString)!)
        
        request.httpMethod = "GET"
        request = addRequestHeaders(request)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 200 {
                
                let mapper = Mapper<User>()
                guard let userSettings = mapper.map(JSONString: String(data: data!, encoding: .utf8)!) else {
                    result(nil)
                    return
                }
                
                result(userSettings)
            } else {
                result(nil)
            }
        }
        
        task.resume()
    }
    
    private static func getUserStats(userId: String) -> User? {
        
        let targetURLString = "https://api.trakt.tv/users/\(userId)/stats"
        var request = URLRequest(url: URL(string: targetURLString)!)
        
        request.httpMethod = "GET"
        request = addRequestHeaders(request)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let result = session.synchronousDataTask(with: request)
        
        let statusCode = (result.urlResponse as! HTTPURLResponse).statusCode
        
        if statusCode == 200 {
            
            let mapper = Mapper<User>()
            guard let user = mapper.map(JSONString: String(data: result.data!, encoding: .utf8)!) else {
                return nil
            }
            return user
        }
        
        return nil
    }
    
    static func getAllShows(useCache: Bool) -> Observable<[WatchedShow]> {
        
        
        let cacheKey = "allShows"
        let remoteValues = Observable<[WatchedShow]>.create { observer in
            self.getWatchedShows(result: { watchedShows in
                
                let newArray = watchedShows!.map { watched -> WatchedShow in
                    let show = getWatchedProgress(watchedShow: watched)
                    if show.nextEpisode != nil {
                        show.nextEpisode = getEpisode(showId: show.show.ids.slug, season: show.nextEpisode.season, number: show.nextEpisode.number)
                    }
                    
                    return show
                }
                
                if let cache = Configuration.getRequestsCache() {
                    
                    let mapper = Mapper<WatchedShow>()
                    let strJSON = mapper.toJSONString(newArray)! as NSString
                    cache.setObject(strJSON as NSString, forKey: cacheKey, expires: .seconds(Constants.requestsCacheTTL))
                    
                }
                
                observer.onNext(newArray)
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
        
        if useCache,
            let cache = Configuration.getRequestsCache(),
            let data = cache.object(forKey: cacheKey) {
            
            let mapper = Mapper<WatchedShow>()
            let shows = mapper.mapArray(JSONString: data as String)!
            
            return Observable.just(shows).concat(remoteValues)
            
        } else {
            return remoteValues
        }
    }

    private static func getWatchedShows(result: @escaping (_ shows: [WatchedShow]?) -> Void) {

        let targetURLString = "https://api.trakt.tv/sync/watched/shows?extended=noseasons"
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

                result(watchedShows)
            } else {
                result(nil)
            }
        }
        
        task.resume()
    }

    private static func getWatchedProgress(watchedShow: WatchedShow) -> WatchedShow {

        let targetURLString = "https://api.trakt.tv/shows/\(watchedShow.show.ids.slug)/progress/watched"
        var request = URLRequest(url: URL(string: targetURLString)!)

        request.httpMethod = "GET"
        request = addRequestHeaders(request)

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let result = session.synchronousDataTask(with: request)
        
        let statusCode = (result.urlResponse as! HTTPURLResponse).statusCode
        
        if statusCode == 200 {
            
            let mapper = Mapper<WatchedShow>()
            guard let showProgress = mapper.map(JSONString: String(data: result.data!, encoding: .utf8)!) else {
                return watchedShow
            }
            
            watchedShow.setProgress(completed: showProgress.completed, aired: showProgress.aired)
            watchedShow.nextEpisode = showProgress.nextEpisode
        }
        
        return watchedShow
    }

    private static func getEpisode(showId: String, season: Int, number: Int) -> Episode {
        
        let targetURLString = "https://api.trakt.tv/shows/\(showId)/seasons/\(season)/episodes/\(number)?extended=full"
        var request = URLRequest(url: URL(string: targetURLString)!)
        
        request.httpMethod = "GET"
        request = addRequestHeaders(request)
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let result = session.synchronousDataTask(with: request)
        
        let statusCode = (result.urlResponse as! HTTPURLResponse).statusCode
        
        if statusCode == 200 {
            
            let mapper = Mapper<Episode>()
            guard let episode = mapper.map(JSONString: String(data: result.data!, encoding: .utf8)!) else {
                return Episode()
            }
            return episode
        }
        
        return Episode()
    }
    
    static func getEpisode(showId: String, season: Int, number: Int) -> Observable<Episode> {
        return Observable<Episode>.create { observer in
            
            let episode: Episode = getEpisode(showId: showId, season: season, number: number)
            observer.onNext(episode)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    //Add to history
}

extension URLSession {
    func synchronousDataTask(with urlRequest: URLRequest) -> (data: Data?, urlResponse: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlRequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}
