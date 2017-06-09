//
//  ViewController.swift
//  Events
//
//  Created by Robert G Tichy on 6/4/17.
//  Copyright © 2017 Robert G Tichy. All rights reserved.
//

import UIKit
import CoreData

//class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVEventControllerDelegate {

    let coreDataObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    var events: NSArray = NSArray()
    var events: [Event] = [Event]()

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addEventPressed(_ sender: Any) {
        print("got here 1")
        performSegue(withIdentifier: "showEvent", sender: nil)
//        print("comes thru here?")
//        loadEvents()
//        tableView.reloadData()
//        
    }
    
    
    func loadEvents() {
        do {
            events = try coreDataObjectContext.fetch(Event.fetchRequest())
        }
        catch {
            let readable_error = error as NSError
            print(readable_error)
        }
        print(events.count)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        tableView.dataSource = self
//        tableView.delegate = self
        loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("inCellForRowAt")
        var identifier: String = ""
        if events[indexPath.row].open == true {
            identifier = "open"
        }
        if events[indexPath.row].open == false {
            identifier = "closed"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)! as UITableViewCell

        cell.textLabel?.text = events[indexPath.row].title
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Selected Row")
        performSegue(withIdentifier: "showEvent", sender: indexPath)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let AVEventController = navigationController.topViewController as! AddViewEventController
        AVEventController.delegate = self
        if sender is NSIndexPath {
            let indexPath = sender as! NSIndexPath
            let event = events[indexPath.row]
            AVEventController.parmEvent?.title = event.title
            AVEventController.parmEvent?.info = event.info
            AVEventController.parmEvent?.start = event.start
            
        }
        else {
            let event = NSEntityDescription.insertNewObject(forEntityName: "Event", into: coreDataObjectContext) as! Event
            event.start = Date() as NSDate?
            event.title = ""
            event.info = ""
            AVEventController.parmEvent = event
        }
    }
    
    func savePressed(controller: AddViewEventController, event: Event?, atRow: NSIndexPath?) {
        print("returning from Save Pressed")
        //            do {
        //                try coreDataObjectContext.save()
        //                print("Stored an event")
        //                self.dismiss(animated: true, completion: nil)
        //            } catch {
        //                let nserror = error as NSError
        //                print("Unresolved error \(nserror), \(nserror.userInfo)")
        //                abort()
        //            }

        loadEvents()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        events.remove(at: indexPath.row)
        tableView.reloadData()
        
    }
}

