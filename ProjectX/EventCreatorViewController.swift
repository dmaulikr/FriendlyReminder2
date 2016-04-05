//
//  EventCreatorViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 2/26/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class EventCreatorViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventTitle: UITextField!
    
    var authID: String?
    var groupEvent: Bool?
    var tapRecognizer: UITapGestureRecognizer? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTitle.delegate = self
        
        // set minimum date to today (can't go back in time)
        let date = NSDate()
        datePicker.minimumDate = date
        configureTapRecognizer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        eventTitle.resignFirstResponder()
        return true
    }
    
    // MARK: - Buttons

    @IBAction func cancelEvent(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func createEvent(sender: AnyObject) {
        // Throw alert if title is nil
        if eventTitle.text == "" {
            let alert = UIAlertController(title: "Event title",
                message: "Event title can't be empty!",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Default) { (action: UIAlertAction) -> Void in
            }
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let date = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.stringFromDate(date)
        
        if groupEvent == true {
            // save to Firebase
            let event = Event(title: eventTitle.text!, date: dateString, members: [authID!: true])
            
            // set event
            let eventRef = FirebaseClient.Constants.EVENT_REF.childByAppendingPath(eventTitle.text!.lowercaseString + "/")
            eventRef.setValue(event.toAnyObject())
            
            // update user
            let userRef = FirebaseClient.Constants.USER_REF.childByAppendingPath(authID! + "/events/")
            userRef.updateChildValues([event.title: true])
            
        } else {
            // save to coreData
            let _ = UserEvent(title: eventTitle.text!, date: dateString, context: self.sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - Keyboard Tap Recognizer
    
    func configureTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}




