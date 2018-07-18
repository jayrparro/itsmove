//
//  DatePickerViewController.swift
//  MyDatePicker
//
//  Created by Leonardo Parro on 15/2/17.
//  Copyright © 2017 Leonardo Parro. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate: class {
    func didSelect(_ sender: DatePickerViewController, date: Date, dateString: String);
}


class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate: DatePickerViewControllerDelegate?
    var tag: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.minimumDate = Date()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancelButtonHandler(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneButtonHandler(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd MMMM yyyy"        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        let strDate = dateFormatter.string(from: datePicker.date)
        delegate?.didSelect(self, date: datePicker.date, dateString: strDate)

        
        self.dismiss(animated: true, completion: nil)
    }
}
