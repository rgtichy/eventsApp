//
//  ViewController.swift
//  Events
//
//  Created by Robert G Tichy on 6/4/17.
//  Copyright © 2017 Robert G Tichy. All rights reserved.
//

import UIKit
import CoreData

    class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVEventControllerDelegate {

    let coreDataObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var events: [Event] = [Event]()
    var open_events: [Event] = [Event]()
    var closed_events: [Event] = [Event]()

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addEventPressed(_ sender: Any) {
        print("got here 1")
        performSegue(withIdentifier: "showEvent", sender: nil)
    }
    func dumpEvents() {
        var idx: Int = 0
        for e in events {
            print("\(idx):  title:\(e.title!), info: \(e.info!), date: \(e.start!), open:\(e.open)")
            idx += 1
        }
    }
    func loadEvents() {
        do {
            print("loadEvents begin:")
            let result = try coreDataObjectContext.fetch(Event.fetchRequest())
            events = result as! [Event]
            dumpEvents()
        }
        catch {
            let readable_error = error as NSError
            print(readable_error)
        }
        print("end of loadEvents events.count= \(events.count)")
        let open = NSPredicate(format: "open = true")
        let closed = NSPredicate(format: "open = false")
        open_events = (events as NSArray).filtered(using: open) as! [Event]
        closed_events = (events as NSArray).filtered(using: closed) as! [Event]
        
        print("Open: \(open_events.count), Closed: \(closed_events.count)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        loadEvents()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections: Int = 0
        if open_events.count>0 && closed_events.count>0 {
            sections = 2
        }
        else {
            if open_events.count>0 || closed_events.count>0 {
                sections = 1
            }
            else {
                sections = 0
            }
        }
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Open Events"
        }
        else {
            return "Closed Events"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnVal: Int = 0
        
        if section == 0 {
            returnVal = open_events.count
        }
        if section == 1 {
            returnVal = closed_events.count
        }
        return returnVal
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier: String = ""
        var rowText: String = ""
        
        if indexPath.section == 0 {
            identifier = "open"
            rowText = open_events[indexPath.row].title!
        }
        else {
            identifier = "closed"
            rowText = closed_events[indexPath.row].title!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)! as UITableViewCell

//        cell.textLabel?.text = events[indexPath.row].title
        cell.textLabel?.text = rowText
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Selected Section: \(indexPath.section), Row @ \(indexPath.row)")
        if indexPath.section == 0 {
            let event = open_events[indexPath.row]
            event.open = !event.open
        }
        if indexPath.section == 1 {
            let event = closed_events[indexPath.row]
            event.open = !event.open
        }
        if coreDataObjectContext.hasChanges {
            do {
                try coreDataObjectContext.save()
                print("Flipped an event")
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
        loadEvents()
        tableView.reloadData()


    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let AVEventController = navigationController.topViewController as! AddViewEventController
        AVEventController.delegate = self
        print("\ninside PrepareForSegue")
        if sender is NSIndexPath {
            let indexPath = sender as! NSIndexPath
            let event = events[indexPath.row]
            print("event:\(indexPath.row):  title:\(event.title!), info: \(event.info!), date: \(event.start!), open:\(event.open)")
            AVEventController.parmEvent?.title = event.title!
            AVEventController.parmEvent?.info = event.info!
            AVEventController.parmEvent?.start = event.start as! Date
            AVEventController.parmIndexPath = indexPath
            print("parmEvent: title:\(AVEventController.parmEvent?.title), info: \(AVEventController.parmEvent?.info), date: \(AVEventController.parmEvent?.start), open:\(AVEventController.parmEvent?.open)")
        }
        else {
            let event = event_struct(title: "", info: "", start: Date(), open: true)
            AVEventController.parmEvent = event
            AVEventController.parmIndexPath = nil
            dumpEvents()
        }
    }
    func savePressed(controller: AddViewEventController, event: event_struct, atRow indexPath: NSIndexPath?) {
        print("returning to Main from Save Pressed")
            if indexPath != nil {
                // locate the correct row in my events array
                events[indexPath!.row].title = event.title
                events[indexPath!.row].info = event.info
                events[indexPath!.row].start = event.start as NSDate?
                events[indexPath!.row].open = true
            }
            else {
                // create a new entry into the Event entity in the coreDataObjectContext
                let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: coreDataObjectContext) as! Event
                newEvent.title = event.title
                newEvent.info = event.info
                newEvent.start = event.start as NSDate?
                newEvent.open = true
            }
        if coreDataObjectContext.hasChanges {
            do {
                try coreDataObjectContext.save()
                print("Stored an event")
                self.dismiss(animated: true, completion: nil)
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }            
        }
        loadEvents()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        coreDataObjectContext.delete(event)
        if coreDataObjectContext.hasChanges {
            do {
                try coreDataObjectContext.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
        events.remove(at: indexPath.row)
        tableView.reloadData()
        
    }
        func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            performSegue(withIdentifier: "showEvent", sender: indexPath)

        }
}

