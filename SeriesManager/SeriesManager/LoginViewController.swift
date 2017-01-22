//
//  ViewController.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 21/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit
import AppController
import Locksmith

class LoginViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        webView.loadRequest(RestAPI.getAuthorizationRequest())
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

                RestAPI.requestForAccessToken(authorizationCode: code, completion: { (success, error) in
                    if success {
                        AppController.didLogin()
                    } else {
                        //TODO: tratar erro
                    }
                })
            }
        }

        return true
    }

}

