//
//  ViewController.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 21/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    let clientID = "f36eefe52b427fd2ed0fb2605fa3f938e2685c49785ddb00c4a2701c375bc2bc"
    let clientSecret = "7e0fafe81508bf8d16c3624f6b989f65196ebf3ddfef23ecba729e9584bfeabd"
    let authorizationEndPoint = "https://trakt.tv/oauth/authorize"
    let accessTokenEndPoint = "https://trakt.tv/oauth/token"
    let redirectURI = "https://com.capivaraec.seriesmanager/callback"

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self

        startAuthorization()
    }

    func startAuthorization() {
        // Specify the response type which should always be "code".
        let responseType = "code"
        let state = "state\(Date().timeIntervalSince1970)"

        // Create the authorization URL string.
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(clientID)&"
        authorizationURL += "redirect_uri=\(redirectURI.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)&"
        authorizationURL += "state=\(state)"

        print(authorizationURL)


        // Create a URL request and load it in the web view.
        let request = URLRequest(url: URL(string: authorizationURL)!)
        webView.loadRequest(request)
    }


    func requestForAccessToken(authorizationCode: String) {
        let grantType = "authorization_code"

        // Set the POST parameters.
        let postParams = ["grant_type" : grantType,
                          "code" : authorizationCode,
                          "redirect_uri" : redirectURI,
                          "client_id" : clientID,
                          "client_secret" : clientSecret]

        let json = try! JSONSerialization.data(withJSONObject: postParams)

        print(postParams)

        // Initialize a mutable URL request object using the access token endpoint URL string.
        var request = URLRequest(url: URL(string: accessTokenEndPoint)!)

        // Indicate that we're about to make a POST request.
        request.httpMethod = "POST"

        // Set the HTTP body using the postData object created above.
        request.httpBody = json

        // Add the required HTTP header field.
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Make the request.
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! HTTPURLResponse).statusCode

            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]

                    let accessToken = dataDictionary["access_token"] as! String

                    UserDefaults.standard.set(accessToken, forKey: "CSMAccessToken")
                    UserDefaults.standard.synchronize()

                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                } catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }

            print("statusCode = \(statusCode)")
        }

        task.resume()
    }


    // MARK: UIWebViewDelegate Functions

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!
        print(url)

        if url.host == "com.capivaraec.seriesmanager" {
            if url.absoluteString.range(of: "code") != nil {
                // Extract the authorization code.
                let urlParts = url.absoluteString.components(separatedBy: "?")
                let code = urlParts[1].components(separatedBy: "=")[1].components(separatedBy: "&")[0]

                requestForAccessToken(authorizationCode: code)
            }
        }

        return true
    }

}

