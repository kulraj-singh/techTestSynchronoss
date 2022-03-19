//
//  SessionRequestSuccess.swift
//  MyTravelHelperTests
//
//  Created by Kulraj on 19/03/22.
//  Copyright © 2022 Sample. All rights reserved.
//

@testable import MyTravelHelper
import Foundation

class SessionRequestSuccess: SessionRequest {

    override func sessionRequest(endPoint: String, params: [String : AnyObject] = [:], method: SessionMethod = .get, success: @escaping ((Data) -> Void), errorBlock: @escaping ((Error) -> Void)) {
        switch endPoint {
        case "getAllStationsXML":
            let xmlText = "<ArrayOfObjStation><objStation><StationDesc>Belfast</StationDesc><StationAlias/><StationLatitude>54.6123</StationLatitude><StationLongitude>-5.91744</StationLongitude><StationCode>BFSTC</StationCode><StationId>228</StationId></objStation></ArrayOfObjStation>"
            let data = Data(xmlText.utf8)
            success(data)
            return
        default:
            break
        }
    }
}
