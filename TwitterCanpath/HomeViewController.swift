//
//  HomeViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2017/01/04.
//  Copyright © 2017 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    var loggedInUserData: AnyObject?
    
    
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    
    var tweets = [AnyObject?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        // get the logged in users details
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observe(.value) { (snapshot: FIRDataSnapshot) in
            
            //store the logged in users details into the variable
            self.loggedInUserData = snapshot
            
            // get all the tweets that are made by the user
            self.databaseRef.child("tweets/\(self.loggedInUser!.uid)").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
                
                self.tweets.append(snapshot)
                
                /*
                self.tableView.insertRows(at: [IndexPath], with: <#T##UITableViewRowAnimation#>)
                */
                
                self.aivLoading.stopAnimating()
                
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "homeViewTableViewCell", for: indexPath) as! HomeViewTableViewCell
        
        //let cell = UITableViewCell()
        //cell.textLabel?.text = "You have no snaps 😂"
        
        let length: Int = self.tweets.count
        
        //let tweet = tweets[(length - 1) - indexPath.row]!.value["text"] as! String
        let tweet = tweets[1]!["text"] as! String
        
        cell.configure(profilePic: nil, name: self.loggedInUserData!.value["name"] as! String, handle: self.loggedInUserData!.value["handle"] as! String, tweet: tweet)
        
        return cell
    }
    
}
