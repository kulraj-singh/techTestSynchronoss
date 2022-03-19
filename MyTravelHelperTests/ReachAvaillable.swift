//
//  ReachAvaillable.swift
//  MyTravelHelperTests
//
//  Created by Kulraj on 19/03/22.
//  Copyright © 2022 Sample. All rights reserved.
//

@testable import MyTravelHelper

class ReachAvaillable: Reach {
    
    override func isNetworkReachable() -> Bool {
        return true
    }

}
