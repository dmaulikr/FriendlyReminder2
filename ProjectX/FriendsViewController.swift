//
//  FriendsViewController.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/17/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UITableViewController {
    
    var friends = [Friend]()
    var membersRef: Firebase?
    var taskCounterRef: Firebase!
    
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
    }
    
    // reloads the tableview data and task array
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // searches for user's friends list
        FacebookClient.sharedInstance().searchForFriendsList(self.membersRef!, controller: self) {
            (friends, picture, error) -> Void in
            self.friends = friends
            self.tableView.reloadData()
            self.activityView.hidden = true
        }
    }
    
    func initNavBar() {
        navigationItem.title = "Friends"
        let infoButton = UIButton(type: UIButtonType.InfoLight) as UIButton
        let rightBarButton = UIBarButtonItem()
        infoButton.frame = CGRectMake(0,0,30,30)
        infoButton.addTarget(self, action: "showInfo", forControlEvents: .TouchUpInside)
        rightBarButton.customView = infoButton
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func showInfo() {
        let alert = UIAlertController(title: "Instructions",
            message: "Tap friends to add them to the event!",
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func configureCell(cell: FriendCell, indexPath: NSIndexPath) {
        let friend = friends[indexPath.row]

        cell.friendName.text = friend.name
        cell.profilePic.image = friend.image
        cell.tintColor = UIColor.orangeColor()
        cell.backgroundColor = UIColor.blackColor()
        if friend.isMember {
            cell.accessoryType = .Checkmark
            cell.addedLabel.hidden = false
        } else {
            // remove checkmark
            cell.accessoryType = .None
            cell.addedLabel.hidden = true
        }
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "FriendCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! FriendCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friend = friends[indexPath.row]
        if friend.isMember == false {
            self.membersRef?.updateChildValues([friend.id: true])
            // initializes path to taskCounter in Firebase
            self.taskCounterRef.updateChildValues([friend.id: 0])
            friend.isMember = true
        } else {
            // removing friend from event
            self.membersRef?.updateChildValues([friend.id: false])
            friend.isMember = false
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
}
