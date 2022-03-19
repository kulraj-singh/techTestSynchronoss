//
//  SearchTrainInteractorTests.swift
//  MyTravelHelperTests
//
//  Created by Kulraj on 19/03/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainInteractorTests: XCTestCase {
    
    var interactor: SearchTrainInteractor!
    
    override func setUp() {
        super.setUp()
        interactor = SearchTrainInteractor()
        interactor.presenter = self
    }
    
    func testFetchAllStations() {
        interactor.reach = ReachNotAvaillable()
        interactor.fetchallStations()
        
        interactor.reach = ReachAvaillable()
        interactor.session = SessionRequestFailure()
        interactor.fetchallStations()
        
        interactor.session = SessionRequestSuccess()
        interactor.fetchallStations()
    }
    
    override func tearDown() {
        super.tearDown()
    }

}

extension SearchTrainInteractorTests: InteractorToPresenterProtocol {
    
    func stationListFetched(list: [Station]) {
        XCTAssert(list.count == 1)
        if list.count > 0 {
            let station = list[0]
            XCTAssert(station.stationId == 228)
            XCTAssert(station.stationCode == "BFSTC")
        }
    }
    
    func fetchedTrainsList(trainsList: [StationTrain]?) {
        //
    }
    
    func showNoTrainAvailbilityFromSource() {
        //
    }
    
    func showNoInterNetAvailabilityMessage() {
        //
    }
    
    
}
