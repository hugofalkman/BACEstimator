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
    var userEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = FIRDatabase.database().reference().child("sweet-items")
        // startObservingDB()
     }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener() { (auth: FIRAuth, user:  FIRUser?) in
            if let use = user {
                self.userEmail = use.email!
                print("Welcome \(use.email!)")
                self.startObservingDB()
            } else {
                print("You need to sign up or login first")
            }
        }
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
    
    @IBAction func loginAndSignUp(sender: UIBarButtonItem) {
        let userAlert = UIAlertController(title: "Login/Sign up", message: "Enter email and password", preferredStyle: .Alert)
        userAlert.addTextFieldWithConfigurationHandler { (textfield: UITextField) in
            textfield.placeholder = "email"
        }
        userAlert.addTextFieldWithConfigurationHandler { (textfield: UITextField) in
            textfield.secureTextEntry = true
            textfield.placeholder = "password"
        }
        
        userAlert.addAction(UIAlertAction(title: "Login", style: .Default){ (action: UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!
            
            FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!) { (user: FIRUser?, error: NSError?) in
                if error != nil {
                    print(error?.description)
                }
            }
        })
        
        userAlert.addAction(UIAlertAction(title: "Sign up", style: .Default) { (action: UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!
            
            FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!) { (user: FIRUser?, error: NSError?) in
                if error != nil {
                    print(error?.description)
                }

            }
        })
        
        self.presentViewController(userAlert, animated: true) {}
    }
    
    @IBAction func addSweet(sender: UIBarButtonItem) {
        let sweetAlert = UIAlertController(title: "New Sweet", message: "Enter your Sweet", preferredStyle: .Alert)
        sweetAlert.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            textField.placeholder = "Your Sweet"
        }
        sweetAlert.addAction(UIAlertAction(title: "Send", style: .Default) { (action: UIAlertAction) in
            if let sweetContent = sweetAlert.textFields?.first?.text {
                let sweet = Sweet(content: sweetContent, addedByUser: self.userEmail!)
                
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
