//
//  UserProfileViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2017/01/10.
//  Copyright © 2017 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    
    
    var loggedInUser: FIRUser?
    var otherUser: NSDictionary?
    var databaseRef: FIRDatabaseReference!
    var loggedInUserData: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //create a reference to the firebase database
        databaseRef = FIRDatabase.database().reference()
        
        //add an observer for the logged in user
        databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observe(FIRDataEventType.value, with: { (snapshot) in
            
            print("VALUE CHANGED IN USER_PROFILES")
            self.loggedInUserData = snapshot.value as? NSDictionary
            //store the key in the users data variable
            self.loggedInUserData?.setValue(self.loggedInUser!.uid, forKey: "uid")
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //add an observer for the user who's profile is being viewed
        //When the followers count is changed, it is updated here!
        //need to add the uid to the user's data
        databaseRef.child("user_profiles").child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            let uid = self.otherUser?["uid"] as! String
            self.otherUser = snapshot.value as? NSDictionary
            //add the uid to the profile
            self.otherUser?.setValue(uid, forKey: "uid")
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //check if the current user is being followed
        //if yes, Enable the UNfollow button
        //if no, Enable the Follow button
        
        databaseRef.child("following").child(self.loggedInUser!.uid).child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            if(snapshot.exists())
            {
                self.followButton.setTitle("Unfollow", for: .normal)
                print("You are following the user")
                
            }
            else
            {
                self.followButton.setTitle("Follow", for: .normal)
                print("You are not following the user")
            }
            
            
        }) { (error) in
            
            print(error.localizedDescription)
        }
        
        
        
        self.name.text = self.otherUser?["name"] as? String
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func followButtonTapped(_ sender: Any) {
        
        let followersRef = "followers/\(self.otherUser?["uid"] as! String)/\(self.loggedInUserData?["uid"] as! String)"
        let followingRef = "following/\(self.loggedInUserData?["uid"] as! String)/\(self.otherUser?["uid"] as! String)"
        
        
        if(self.followButton.titleLabel?.text == "Follow")
        {
            print("follow user")
            
            let followersData = ["name":self.loggedInUserData?["name"] as! String,
                                 "handle":self.loggedInUserData?["handle"] as! String,
                                 "profile_pic":"\(self.loggedInUserData?["profile_pic"])"]
            
            let followingData = ["name":self.otherUser?["name"] as! String,
                                 "handle":self.otherUser?["handle"] as! String,
                                 "profile_pic":"\(self.otherUser?["profile_pic"])"]
            
            //"profile_pic":self.otherUser?["profile_pic"] != nil ? self.loggedInUserData?["profile_pic"] as! String : ""
            
            print("print followersData------------------------------")
            print(followersRef)
            print(followersData)
            print("FoloWIGNDATA-------------------")
            print(followingRef)
            print(followingData)
            
            
            let childUpdates = [followersRef:followersData,
                                followingRef:followingData]
            
            
            databaseRef.updateChildValues(childUpdates)
            
            print("data updated")
            
            
            
            
            //update following count under the logged in user
            //update followers count in the user that is being followed
            let followersCount:Int?
            let followingCount:Int?
            if(self.otherUser?["followersCount"] == nil)
            {
                //set the follower count to 1
                followersCount=1
            }
            else
            {
                followersCount = self.otherUser?["followersCount"] as! Int + 1
            }
            
            //check if logged in user  is following anyone
            //if not following anyone then set the value of followingCount to 1
            if(self.loggedInUserData?["followingCount"] == nil)
            {
                followingCount = 1
            }
                //else just add one to the current following count
            else
            {
                
                followingCount = self.loggedInUserData?["followingCount"] as! Int + 1
            }
            
            databaseRef.child("user_profiles").child(self.loggedInUser!.uid).child("followingCount").setValue(followingCount!)
            databaseRef.child("user_profiles").child((self.otherUser!["uid"] as? String)!).child("followersCount").setValue(followersCount!)
            
            //var followersCountRef = "user_profiles/\(self.otherUser?["uid"])followersCount"
            
            //"following/\(self.loggedInUserData?["uid"] as? String)/\(self.otherUser?["uid"] as? String)"
            
            //var updates = [followersCountRef: followersCount!]
            
            //databaseRef.updateChildValues(updates)
            
        }
        else
        {
            databaseRef.child("user_profiles").child(self.loggedInUserData?["uid"]! as! String).child("followingCount").setValue(self.loggedInUserData!["followingCount"] as! Int - 1)
            databaseRef.child("user_profiles").child(self.otherUser?["uid"] as! String).child("followersCount").setValue(self.otherUser!["followersCount"] as! Int - 1)
            
            let followersRef = "followers/\(self.otherUser?["uid"] as! String)/\(self.loggedInUserData?["uid"] as! String)"
            let followingRef = "following/" + (self.loggedInUserData?["uid"] as! String) + "/" + (self.otherUser?["uid"] as! String)
            
            
            let childUpdates = [followingRef:NSNull(),followersRef:NSNull()]
            databaseRef.updateChildValues(childUpdates)
            
            
        }
        
    }
    
    
}
