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
    //var loggedInUserData: AnyObject?
    var loggedInUserData = User()
    
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    
    var tweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        
        // get the logged in users details
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observe(.value) { (snapshot: FIRDataSnapshot) in
        
            
            //store the logged in users details into the variable
            
            self.loggedInUserData.name = (snapshot.value! as AnyObject)["name"] as! String
            self.loggedInUserData.handle = (snapshot.value! as AnyObject)["handle"] as! String
 
            
            // get all the tweets that are made by the user
            //self.databaseRef.child("tweets/\(self.loggedInUser!.uid)").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            self.databaseRef.child("tweets").child(self.loggedInUser!.uid).observe(FIRDataEventType.childAdded, with: {(snapshot) in
                
                let tweet = Tweet()
                tweet.text = (snapshot.value! as AnyObject)["text"] as! String

                self.tweets.append(tweet)

                /*
                self.tableView.insertRows(at: [IndexPath], with: <#T##UITableViewRowAnimation#>)
                */
                
                self.aivLoading.stopAnimating()
                
                self.tableView.reloadData()
            })
        }
        
        self.tableView.estimatedRowHeight = 250
        self.tableView.rowHeight = 200
        //self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    */
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "homeViewTableViewCell", for: indexPath) as! HomeViewTableViewCell
 
        let length: Int = self.tweets.count

        let tweet = tweets[(length - 1) - indexPath.row].text
        
        cell.configure(profilePic: nil, name: self.loggedInUserData.name, handle: self.loggedInUserData.handle, tweet: tweet)
        
        return cell
    }
    
}
