//
//  BookingViewController.swift
//  MySmove
//
//  Created by Leonardo Parro on 16/7/18.
//  Copyright © 2018 Leonardo Parro. All rights reserved.
//

import UIKit
import CoreLocation

class BookingViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var bookingTableView: UITableView!
    
    var bookStartDate: Date?
    var bookEndDate: Date?
    var allBookings = [Booking]()    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Book A Car"
        
        updateDateDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showDatePicker(_ tag: Int) {
        let dVC = DatePickerViewController(nibName: "DatePickerViewController", bundle: nil)
        dVC.modalPresentationStyle = .custom
        dVC.transitioningDelegate = self
        dVC.delegate = self
        dVC.tag = tag
        
        self.present(dVC, animated: true, completion: nil)
    }
    
    func updateDateDisplay() {
        let todayDate = Date()
        
        if let aStartDate = bookStartDate {
            let dateStr = Utils.convertDateToStringFormat(aStartDate)
            startDateLabel.text = dateStr
        } else {
            bookStartDate = todayDate
            startDateLabel.text = Utils.convertDateToStringFormat(todayDate)
        }

        if let aEndDate = bookEndDate {
            let dateStr = Utils.convertDateToStringFormat(aEndDate)
            endDateLabel.text = dateStr
        } else {
            bookEndDate = todayDate
            endDateLabel.text = Utils.convertDateToStringFormat(todayDate)
        }
    }
    
    func updateResultsDisplay() {
        resultsLabel.text = "Results: \(allBookings.count)"
        bookingTableView.reloadData()
    }
    
    func getBookingAvailability() {
        guard let aBookStartDate = bookStartDate else { return }
        guard let aBookEndDate = bookEndDate else { return }
        
        let startTime = aBookStartDate.timeIntervalSince1970
        let endTime = aBookEndDate.timeIntervalSince1970
        
        Fetcher.sharedInstance.getBookingAvailability(
            startTime: startTime,
            endTime: endTime) { (result) in
                switch result {
                case .success(let bookings):
                    self.allBookings.removeAll()
                    self.allBookings = bookings
                    
                    self.updateResultsDisplay()
                    
                case .failure(let error):
                    debugPrint("Error: \(error.localizedDescription)")
                }
        }
    }
    
    // MARK: - IB Actions
    @IBAction func onShowStartDateButtonHandler(_ sender: UIButton) {
        showDatePicker(sender.tag)
    }
    
    @IBAction func onShowEndDateButtonHandler(_ sender: UIButton) {
        showDatePicker(sender.tag)
    }
    
    @IBAction func onCheckAvailabilityButtonHandler(_ sender: UIButton) {
        if Utils.isInternetAvailable() {
            getBookingAvailability()
        }
    }
}

/**************************************************************************/
// MARK: - DatePickerViewControllerDelegate
/**************************************************************************/
extension BookingViewController: DatePickerViewControllerDelegate {
    
    func didSelect(_ sender: DatePickerViewController, date: Date, dateString: String) {
        if sender.tag == 100 {
            bookStartDate = date
        } else {
            bookEndDate = date
        }
        
        updateDateDisplay()
    }
}

/**************************************************************************/
// MARK: - UIViewControllerTransitioningDelegate
/**************************************************************************/
extension BookingViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}

/**************************************************************************/
// MARK: - HalfSizePresentationController
/**************************************************************************/
class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0,
                      y: containerView!.bounds.height * 0.60,
                      width: containerView!.bounds.width,
                      height: containerView!.bounds.height/2)
    }
}

/**************************************************************************/
// MARK: - UITableViewDataSource, UITableViewDelegate
/**************************************************************************/
extension BookingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.allBookings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let booking = self.allBookings[section]
        
        return booking.dropoffLocations.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30.0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingItemCellIdentifier",
                                                 for: indexPath) as! BookingItemCell
        
        // Configure the cell...
        let booking = self.allBookings[indexPath.section]
        booking.getStartLocationAddress { address in
            cell.startAddressLabel.text = "Start: \(address)"
        }
        
        let dropOffLocation = booking.dropoffLocations[indexPath.row]
        let loc = CLLocation(latitude: dropOffLocation.location[0], longitude: dropOffLocation.location[1])
        booking.getLocationAddress(location: loc) { address in
            cell.dropOffAddressLabel.text = "End: \(address)"
        }
        
        cell.numOfCarsLabel.text = "Cars available: \(booking.availableCars)"
        
        return cell
    }
}
