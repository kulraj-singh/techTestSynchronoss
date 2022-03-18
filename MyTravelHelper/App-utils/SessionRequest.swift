//
//  SessionRequest.swift
//  MyTravelHelper
//
//  Created by Kulraj on 18/03/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import Foundation

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

class SessionRequest {
    
    let baseUrl = "http://api.irishrail.ie/realtime/realtime.asmx"
    
    func sessionRequest(endPoint: String, params: [String: AnyObject] = [:], method: Method = .get, success: @escaping((Data) -> Void), errorBlock: @escaping((Error) -> Void)) {
        var urlString = baseUrl + "/" + endPoint
        if params.keys.count > 0 {
            urlString.append("?")
        }
        for key in params.keys {
            if let value = params[key] {
                urlString.append("\(key)=\(value)&")
            }
        }
        guard let url = URL(string: urlString) else {
            errorBlock(NSError(domain: "bad url", code: 404, userInfo: nil))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, urlResponse, error in
            if let data = data {
                success(data)
            } else if let error = error {
                errorBlock(error)
            }
        })
        dataTask.resume()
    }
}
