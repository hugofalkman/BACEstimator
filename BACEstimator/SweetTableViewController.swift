//
//  SweetTableViewController.swift
//  BACEstimator
//
//  Created by H Hugo Falkman on 2016-08-05.
//  Copyright © 2016 H Hugo Falkman. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SweetTableViewController: UITableViewController {

    var dbRef: FIRDatabaseReference!
    var sweets = [Sweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = FIRDatabase.database().reference().child("sweet-items")
        startObservingDB()
     }

    func startObservingDB() {
        dbRef.observeEventType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
            var newSweets = [Sweet]()
            
            for sweet in snapshot.children {
                let sweetObject = Sweet(snapshot: sweet as! FIRDataSnapshot)
                newSweets.append(sweetObject)
            }
            
            self.sweets = newSweets
            self.tableView.reloadData()
            
        }) { (error: NSError) in
                print(error.description)
        }
    }
    
    @IBAction func addSweet(sender: UIBarButtonItem) {
        let sweetAlert = UIAlertController(title: "New Sweet", message: "Enter your Sweet", preferredStyle: .Alert)
        sweetAlert.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            textField.placeholder = "Your Sweet"
        }
        sweetAlert.addAction(UIAlertAction(title: "Send", style: .Default) { (action: UIAlertAction) in
            if let sweetContent = sweetAlert.textFields?.first?.text {
                let sweet = Sweet(content: sweetContent, addedByUser: "HugoFalkman")
                
                let sweetRef = self.dbRef.child(sweetContent.lowercaseString)
                
                sweetRef.setValue(sweet.toAnyObject())
            }
        })
        
        self.presentViewController(sweetAlert, animated: true) {}
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sweets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let sweet = sweets[indexPath.row]
        
        cell.textLabel?.text = sweet.content
        cell.detailTextLabel?.text = sweet.addedByUser

        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let sweet = sweets[indexPath.row]
            sweet.itemRef?.removeValue()
        }
    }
}
