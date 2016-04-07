//
//  TaskViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/10/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class TaskViewController: UITableViewController {
    var tasks = [Task]()
    var ref: Firebase? // reference to all tasks
    var eventRef: Firebase? // for friendVC
    var userRef: Firebase?
    var userName: String?
    var eventTitle: String!
    
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = eventTitle
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTask")
        let addFriends = UIBarButtonItem(title: "Friends", style: .Plain, target: self, action: "addFriends")

        navigationItem.rightBarButtonItems = [addFriends, addButton]
        
        
        userRef!.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.userName = snapshot.value["name"] as? String
        })
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ref!.observeEventType(.Value, withBlock: { snapshot in
            
            var newTasks = [Task]()
            
            for task in snapshot.children {
                let task = Task(snapshot: task as! FDataSnapshot)
                newTasks.append(task)
            }
            
            self.tasks = newTasks
            self.tableView.reloadData()
            self.activityView.hidden = true
        })
    }
    
    // MARK: - Take Task
    @IBAction func takeTask(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! TaskCell
        
        let indexPath = tableView.indexPathForCell(cell)
        let task = tasks[indexPath!.row]

        cell.takeTask.hidden = true
        cell.assignedToLabel.hidden = false
        cell.assignedPeople.hidden = false
        if cell.assignedPeople.text == "" {
            task.ref?.childByAppendingPath("inCharge").setValue([self.userName!])
            //cell.assignedPeople.text?.appendContentsOf(self.userName!)
        }
    }
    
    func addTask() {
        // alert to add task
        
        // Alert View for input
        let alert = UIAlertController(title: "Task creation",
            message: "Add a task",
            preferredStyle: .Alert)
        
        let createAction = UIAlertAction(title: "Create",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                if alert.textFields![0].text == "" {
                    let alert2 = UIAlertController(title: "Task title",
                        message: "Task title can't be empty!",
                        preferredStyle: .Alert)
                    
                    let cancelAction = UIAlertAction(title: "OK",
                        style: .Default) { (action: UIAlertAction) -> Void in
                    }
                    alert2.addAction(cancelAction)
                    
                    self.presentViewController(alert2, animated: true, completion: nil)
                    return
                    
                    
                }
                let textField = alert.textFields![0]
                let taskRef = self.ref!.childByAppendingPath(textField.text!.lowercaseString + "/")

                let task = Task(title: textField.text!, creator: self.userName!, ref: taskRef)

                taskRef.setValue(task.toAnyObject())
                //self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        // fixes collection view error
        alert.view.setNeedsLayout()
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func addFriends() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FriendsViewController") as! FriendsViewController
        controller.membersRef = eventRef?.childByAppendingPath("members/")
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        return tasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "TaskCell"
        
        let task = tasks[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! TaskCell
        
        // This is the new configureCell method
        //configureCell(cell, event: event)
        cell.taskDescription.text = task.title
        cell.creator.text = task.creator
        cell.selectionStyle = .None
        
        if task.inCharge == ["noone"] {
            // no one assigned yet
            print("noone")
        } else {
            //var assigned: String
            cell.takeTask.hidden = true
            cell.assignedToLabel.hidden = false
            cell.assignedPeople.hidden = false
            for name in task.inCharge {
               // print(name)
               // print(name as String)
                cell.assignedPeople.text? = name + ", "
            }
            cell.assignedPeople.text? = String(cell.assignedPeople.text!.characters.dropLast().dropLast())
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.None
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                let task = tasks[indexPath.row]
                print("\(task.ref)")
                task.ref!.removeValue()
            default:
                break
            }
    }
}