//
//  SessionRequestFailure.swift
//  MyTravelHelperTests
//
//  Created by Kulraj on 19/03/22.
//  Copyright © 2022 Sample. All rights reserved.
//

@testable import MyTravelHelper
import Foundation

class SessionRequestFailure: SessionRequest {

    override func sessionRequest(endPoint: String, params: [String : AnyObject] = [:], method: SessionMethod = .get, success: @escaping ((Data) -> Void), errorBlock: @escaping ((Error) -> Void)) {
        let error = NSError(domain: "some dummy error", code: 500, userInfo: nil)
        errorBlock(error)
    }
}
