//
//  RSSFeedResultsViewController.swift
//  Cloudy
//
//  Created by Ganesh on 19/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser
import WebKit

class RSSFeedResultsViewController: UIViewController, WKNavigationDelegate {
    
    //Variable declaration
    var rssItemURL: String?
    
    //Storyboard elements
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Override methos for initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        rssItemURL =  rssItemURL!.replacingOccurrences(of: " ", with:"%20")
        rssItemURL =  rssItemURL!.replacingOccurrences(of: "\n", with:"")
        webView.load(URLRequest(url: URL(string: (rssItemURL!))!))
        //Adding the activity indicator that shows the loading screen while loading the page
        webView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        // Do any additional setup after loading the view.
    }
    
    //methods definitions for view WK website when it works
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
   //methods definitions for view Wk website when it fails
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    //methods definitions for view Wk website when it fails
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

}
