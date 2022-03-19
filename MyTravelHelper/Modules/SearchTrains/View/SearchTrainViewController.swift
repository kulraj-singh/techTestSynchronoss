//
//  SearchTrainViewController.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit
import SwiftSpinner
import DropDown

class SearchTrainViewController: UIViewController {
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var sourceTxtField: UITextField!
    @IBOutlet weak var trainsListTable: UITableView!
    @IBOutlet weak var favoriteToggleView: UIView!
    @IBOutlet weak var stationTextLabel: UILabel!
    @IBOutlet weak var sourceRadioButton: UIButton!
    @IBOutlet weak var destinationRadioButton: UIButton!

    let favoriteStationCodeKey: String = "favoriteStationCodeKey"
    
    var stationsList:[Station] = [Station]() {
        didSet {
            filteredStationsList = stationsList
            let favoriteStationId = UserDefaults.standard.integer(forKey: favoriteStationCodeKey)
            let stationsWithFavoriteId = stationsList.filter({
                return $0.stationId == favoriteStationId
            })
            favoriteStation = stationsWithFavoriteId.first
        }
    }
    var filteredStationsList: [Station] = []
    var favoriteStation: Station? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.actionOnFavoriteStation()
            }
        }
    }
    
    func actionOnFavoriteStation() {
        if let favoriteStation = favoriteStation {
            
            favoriteToggleView.isHidden = false
            stationTextLabel.text = favoriteStation.stationDesc
            if sourceRadioButton.isSelected {
                sourceTxtField.text = favoriteStation.stationDesc
                transitPoints.source = favoriteStation.stationDesc
            }
            if destinationRadioButton.isSelected {
                destinationTextField.text = favoriteStation.stationDesc
                transitPoints.destination = favoriteStation.stationDesc
            }
            UserDefaults.standard.set(favoriteStation.stationId, forKey: favoriteStationCodeKey)
        } else {
            favoriteToggleView.isHidden = true
            UserDefaults.standard.set(-1, forKey: favoriteStationCodeKey)
        }
    }
    var trains:[StationTrain] = [StationTrain]()
    var presenter:ViewToPresenterProtocol?
    var dropDown = DropDown()
    var transitPoints:(source:String,destination:String) = ("","")

    override func viewDidLoad() {
        super.viewDidLoad()
        trainsListTable.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        if stationsList.count == 0 {
            SwiftSpinner.useContainerView(view)
            SwiftSpinner.show("Please wait loading station list ....")
            presenter?.fetchallStations()
        }
    }

    @IBAction func searchTrainsTapped(_ sender: Any) {
        view.endEditing(true)
        if transitPoints.source.isEmpty || transitPoints.destination.isEmpty {
            showAlert(title: "Alert", message: "source and destination should be selected", actionTitle: "OK")
            print("source = \(transitPoints.source), destination = \(transitPoints.destination)")
            return
        }
        showProgressIndicator(view: self.view)
        presenter?.searchTapped(source: transitPoints.source, destination: transitPoints.destination)
    }
    
    @IBAction func sourceRadioButtonClicked(_ sender: Any) {
        sourceTxtField.text = favoriteStation?.stationDesc
        transitPoints.source = favoriteStation?.stationDesc ?? ""
        
        if destinationTextField.text != nil,
           favoriteStation?.stationDesc == destinationTextField.text {
            destinationTextField.text = ""
            transitPoints.destination = ""
        }
        sourceRadioButton.isSelected = true
        destinationRadioButton.isSelected = false
    }
    
    @IBAction func destinationRadioButtonClicked(_ sender: Any) {
        destinationTextField.text = favoriteStation?.stationDesc
        transitPoints.destination = favoriteStation?.stationDesc ?? ""
        
        if sourceTxtField.text != nil,
           favoriteStation?.stationDesc == sourceTxtField.text {
            sourceTxtField.text = ""
            transitPoints.source = ""
        }
        sourceRadioButton.isSelected = false
        destinationRadioButton.isSelected = true
    }
}

extension SearchTrainViewController:PresenterToViewProtocol {
    func showNoInterNetAvailabilityMessage() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Internet", message: "Please Check you internet connection and try again", actionTitle: "Okay")
    }

    func showNoTrainAvailbilityFromSource() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "No Trains", message: "Sorry No trains arriving source station in another 90 mins", actionTitle: "Okay")
    }

    func updateLatestTrainList(trainsList: [StationTrain]) {
        hideProgressIndicator(view: self.view)
        trains = trainsList
        trainsListTable.isHidden = false
        trainsListTable.reloadData()
    }

    func showNoTrainsFoundAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        trainsListTable.isHidden = true
        showAlert(title: "No Trains", message: "Sorry No trains Found from source to destination in another 90 mins", actionTitle: "Okay")
    }

    func showAlert(title:String,message:String,actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showInvalidSourceOrDestinationAlert() {
        trainsListTable.isHidden = true
        hideProgressIndicator(view: self.view)
        showAlert(title: "Invalid Source/Destination", message: "Invalid Source or Destination Station names Please Check", actionTitle: "Okay")
    }

    func saveFetchedStations(stations: [Station]?) {
        if let _stations = stations {
          self.stationsList = _stations
        }
        SwiftSpinner.hide()
    }
}

extension SearchTrainViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown = DropDown()
        /*** IMPORTANT PART FOR CUSTOM CELLS ***/
        dropDown.cellNib = UINib(nibName: "FavoriteDropDownCell", bundle: nil)
        dropDown.customCellConfiguration = { [weak self] (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? FavoriteDropDownCell else { return }

            if let favoriteStationText = self?.favoriteStation?.stationDesc,
               favoriteStationText == item {
                cell.favoriteIcon.isHighlighted = true
            }
            cell.favoriteToggled = { [weak self] isFavorite in
                guard let weakSelf = self else {
                    return
                }
                if isFavorite {
                    if index < weakSelf.filteredStationsList.count {
                        self?.favoriteStation = weakSelf.filteredStationsList[index]
                    }
                } else {
                    self?.favoriteStation = nil
                }
                weakSelf.dropDown.reloadAllComponents()
            }
        }
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = stationsList.map {$0.stationDesc}
        dropDown.selectionAction = { (index: Int, item: String) in
            if textField == self.sourceTxtField {
                self.transitPoints.source = item
            }else {
                self.transitPoints.destination = item
            }
            textField.text = item
        }
        dropDown.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dropDown.hide()
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let inputedText = textField.text {
            var desiredSearchText = inputedText
            if string != "\n" && !string.isEmpty{
                desiredSearchText = desiredSearchText + string
            }else {
                desiredSearchText = String(desiredSearchText.dropLast())
            }

            filteredStationsList = stationsList.filter({
                if desiredSearchText.count == 0 {
                    return true
                }
                return $0.stationDesc.lowercased().contains(desiredSearchText.lowercased())
            })
            let filteredStations = filteredStationsList.map({
                return $0.stationDesc
            })
            dropDown.dataSource = filteredStations
            dropDown.show()
           
            dropDown.reloadAllComponents()
        }
        return true
    }
}

extension SearchTrainViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "train", for: indexPath) as! TrainInfoCell
        let train = trains[indexPath.row]
        cell.trainCode.text = train.trainCode
        cell.souceInfoLabel.text = train.stationFullName
        cell.sourceTimeLabel.text = train.expDeparture
        if let _destinationDetails = train.destinationDetails {
            cell.destinationInfoLabel.text = _destinationDetails.locationFullName
            cell.destinationTimeLabel.text = _destinationDetails.expDeparture
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
