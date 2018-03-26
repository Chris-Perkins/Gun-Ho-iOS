//
//  WebRequestHandler.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 3/25/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//
// A simple class that creates web requests to our server using the singleton pattern

import Foundation
import SwiftyJSON

class WebRequestHandler {
    private static var activeInstance: WebRequestHandler?
    
    // Returns or creates and returns the shared instance
    public static var shared: WebRequestHandler {
        if let instance = activeInstance {
            return instance
        } else {
            activeInstance = WebRequestHandler()
            return activeInstance!
        }
    }
    
    private init() {}
    
    // URL string constants
    
    private let baseURL     = "http://64.37.54.24/"
    private let addUserURL  = "addUser.php/"
    private let loginURL    = "login.php/"
    private let addScoreURL = "addUserScore.php"

    // MARK: Interfaces for performWebRequest method
    
    func attemptSignUp(withUsername username: String,
                       andPassword password: String,
                       actionOnCompleteWithSuccess: @escaping (Bool, Error?) -> ()) {
        
        let json = JSON(["username":username,
                         "nickname":username,
                         "password":password.md5])
        performWebRequest(toURLString: baseURL + addUserURL,
                          withJSON: json,
                          actionOnCompleteWithSuccess: actionOnCompleteWithSuccess)
    }
    
    func attemptLogin(withUsername username: String,
                      andPassword password:String,
                      actionOnCompleteWithSuccess: @escaping (Bool, Error?) -> ()) {
        let json = JSON(["username":username, "password":password.md5])
        
        performWebRequest(toURLString: baseURL + loginURL,
                          withJSON: json,
                          actionOnCompleteWithSuccess: actionOnCompleteWithSuccess)
    }
    
    func attemptPostScore(toUsername username: String,
                          andScore score: Int,
                          actionOnCompleteWithSuccess: @escaping (Bool, Error?) -> ()) {
        
        let json = JSON(["username":username, "score":"\(score)"])
        
        performWebRequest(toURLString: baseURL + addScoreURL,
                          withJSON: json,
                          actionOnCompleteWithSuccess: actionOnCompleteWithSuccess)
    }
    
    // MARK: The main course; web request function
    
    // Attempts to perform a web request to some given url with some json
    // Created this function due to redundancy in above functions.
    func performWebRequest(toURLString urlString: String,
                           withJSON json: JSON,
                           actionOnCompleteWithSuccess: @escaping (Bool, Error?) -> ()) {
        
        let webURL     = URL(string: urlString)!
        var webRequest = URLRequest(url: webURL)
        
        webRequest.httpMethod = "POST"
        webRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data:Data = try! json.rawData()
        webRequest.httpBody = data
        
        let task = URLSession.shared.dataTask(with: webRequest) { data, response, error in
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                OperationQueue.main.addOperation {
                    actionOnCompleteWithSuccess(true, error)
                }
            } else {
                OperationQueue.main.addOperation {
                    actionOnCompleteWithSuccess(false, error)
                }
            }
        }
        task.resume()
    }
}
