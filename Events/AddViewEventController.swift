//
//  AddViewEventController.swift
//  Events
//
//  Created by Robert G Tichy on 6/4/17.
//  Copyright © 2017 Robert G Tichy. All rights reserved.
//

import UIKit
//import CoreData

class AddViewEventController: UIViewController {
    
    let coreDataObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var infoInput: UITextView!
    @IBOutlet weak var startInput: UIDatePicker!
    
    weak var delegate: AVEventControllerDelegate?
    var parmEvent: event_struct?
    var parmIndexPath: NSIndexPath?
    
    @IBAction func pickedDateTime(_ sender: UIDatePicker) {
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: UIButton) {
        print("INSIDE AddView Event Controller: save pressed")
        let event = event_struct(title: titleInput.text!, info: infoInput.text, start: (startInput.date as NSDate) as Date, open: true)
        if titleInput.text != "" {
            print("*** Date? ***")
            print(startInput.date)
            print("*** Date? ***")
            print(event.start)
            if ((parmIndexPath) != nil) {
                delegate?.savePressed(controller: self, event: event, atRow: parmIndexPath)
            } else {
                delegate?.savePressed(controller: self, event: event, atRow: nil)
            }
        self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if parmIndexPath != nil {
            print("inside viewDidLoad()")
            print("\(parmIndexPath?.section), \(parmIndexPath?.row)")
            print("event (struct): \(parmEvent?.title), \(parmEvent?.info), \(parmEvent?.start), \(parmEvent?.open)")
            titleInput.text = parmEvent?.title
            infoInput.text = parmEvent?.info
            startInput.date = (parmEvent?.start)! as Date
        }
        else {
            print("add mode")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
