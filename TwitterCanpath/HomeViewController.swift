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
import SDWebImage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    //var loggedInUserData: AnyObject?
    var loggedInUserData = User()
    
    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    
    var tweets: [Tweet] = []
    
    var defaultImageViewHeightConstrant: CGFloat = 77
    
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
                
                print("--------------------------------------------")
                print("blow line is the picture url")
                print((snapshot.value! as AnyObject)["picture"])
                print("--------------------------------------------")
                
                
                if ((snapshot.value! as AnyObject)["picture"] as? String != nil) {
                //if let picture = (snapshot.value! as AnyObject)["picture"]{
                    print("picture is here!")
                    let picture = (snapshot.value! as AnyObject)["picture"] as! String
                    if picture == ""{
                        tweet.picture = ""
                    } else {
                        tweet.picture = picture as! String
                    }
                } else {
                    print("this tweet does not have picture!")
                }
                
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
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapMediaTweet(_:)))
        
        cell.tweetImage.addGestureRecognizer(imageTap)
        
        
        print("--------------------------------------------")
        print(tweets[(length - 1) - indexPath.row])
        print("--------------------------------------------")
        
        if(tweets[(length - 1) - indexPath.row].picture == ""){
            print("this is empty picture")
            cell.tweetImage.isHidden = true
            cell.imageViewHeightConstraint.constant = 0
        } else {
            print("this includes picture")
            cell.tweetImage.isHidden = false
            cell.imageViewHeightConstraint.constant = defaultImageViewHeightConstrant
            
            let picture = tweets[(length - 1) - indexPath.row].picture
            
            cell.tweetImage.layer.cornerRadius = 10
            cell.tweetImage.layer.borderWidth = 3
            cell.tweetImage.layer.borderColor = UIColor.white.cgColor
            
            cell.tweetImage.sd_setImage(with: URL(string: picture))
            
        }
        
        
        cell.configure(profilePic: nil, name: self.loggedInUserData.name, handle: self.loggedInUserData.handle, tweet: tweet)
        
        return cell
    }
    
    @IBAction func didTapMediaTweet(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
        
        //tap.delegate = self;
        
        newImageView.addGestureRecognizer(tap)
        
        self.view.addSubview(newImageView)
    }
    
    func dismissFullScreenImage(sender: UITapGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "FindUserSegue"){
            let showFollowUsersTableViewController = segue.destination as! FollowUsersTableViewController
            
            showFollowUsersTableViewController.loggedInUser = self.loggedInUser as? FIRUser
        }
    }
}
