//
//  ViewController.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 21/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: URL(string: "https://trakt.tv/oauth/authorize?client_id=f36eefe52b427fd2ed0fb2605fa3f938e2685c49785ddb00c4a2701c375bc2bc&redirect_uri=cec-series%3A%2F%2Fcallback&response_type=code")!)
        webView.loadRequest(request)
    }

}

