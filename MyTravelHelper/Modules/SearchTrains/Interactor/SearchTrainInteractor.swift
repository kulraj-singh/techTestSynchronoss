//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing

class SearchTrainInteractor: PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?
    
    var session = SessionRequest()

    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
            session.sessionRequest(endPoint: "getAllStationsXML", success: { [weak self] response in
                let station = try? XMLDecoder().decode(Stations.self, from: response)
                self?.presenter?.stationListFetched(list: station!.stationsList)
            }, errorBlock: { [weak self] _ in
                self?.presenter?.showNoInterNetAvailabilityMessage()
            })
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        let params = ["StationCode": sourceCode as AnyObject]
        if Reach().isNetworkReachable() {
            session.sessionRequest(endPoint: "getStationDataByCodeXML", params: params, success: { [weak self] response in
                let stationData = try? XMLDecoder().decode(StationData.self, from: response)
                if let _trainsList = stationData?.trainsList {
                    self?.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                } else {
                    self?.presenter?.showNoTrainAvailbilityFromSource()
                }
            }, errorBlock: { [weak self] _ in
                self?.presenter?.showNoInterNetAvailabilityMessage()
            })
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        let group = DispatchGroup()
        for index  in 0...trainsList.count-1 {
            group.enter()
            
            var params: [String: AnyObject] = [:]
            params["TrainId"] = trainsList[index].trainCode as AnyObject
            params["TrainDate"] = dateString as AnyObject
            
            session.sessionRequest(endPoint: "getTrainMovementsXML", params: params, success: { [weak self] response in
                guard let weakSelf = self else {
                    self?.presenter?.showNoInterNetAvailabilityMessage()
                    return
                }
                let trainMovements = try? XMLDecoder().decode(TrainMovementsData.self, from: response)
                if let _movements = trainMovements?.trainMovements {
                    let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(weakSelf._sourceStationCode) == .orderedSame})
                    let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(weakSelf._destinationStationCode) == .orderedSame})
                    let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(weakSelf._destinationStationCode) == .orderedSame}
                    let isDestinationAvailable = desiredStationMoment.count == 1

                    if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                        _trainsList[index].destinationDetails = desiredStationMoment.first
                    }
                }
                group.leave()
                }, errorBlock: { [weak self] _ in
                    group.leave()
                    self?.presenter?.showNoInterNetAvailabilityMessage()
            })
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self?.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
