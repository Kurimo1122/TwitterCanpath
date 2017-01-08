//
//  MeViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2017/01/08.
//  Copyright © 2017 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

import SDWebImage

class MeViewController: UIViewController {
    
    @IBOutlet weak var tweetsContainer: UIView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var likesContainer: UIView!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var about: UITextField!
    
    var loggedInUser: AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observe(.value) { (snapshot: FIRDataSnapshot) in
            let user = User()
            
            /*
            user.name = (snapshot.value! as AnyObject)["name"] as! String
            user.handle = (snapshot.value! as AnyObject)["handle"] as! String
            */
            
            let value = (snapshot.value! as AnyObject)
            print(value)
            
            self.name.text = value["name"] as! String
            
            self.handle.text = value["handle"] as! String
            
            /*
            self.name.text = value["name"] as! String

            self.handle.text = (snapshot.value! as AnyObject)["handle"] as! String
            */
            //initiallly the user will not have an about data
            
            if (value["about"]! != nil){
                self.about.text = value["about"]! as! String
            }
            
            if (value["profile_pic"]! != nil){
                
                user.profile_pic = value["profile_pic"]! as! String
                let databaseProfilePic = user.profile_pic
                
                self.profilePicture.layer.cornerRadius = 10.0
                self.profilePicture.layer.borderColor = UIColor.white.cgColor
                self.profilePicture.layer.masksToBounds = true
                
                self.profilePicture.sd_setImage(with: URL(string: databaseProfilePic))
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        try! FIRAuth.auth()!.signOut()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let welcomeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "welcomeViewController")
        
        self.present(welcomeViewController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func showComponents(_ sender: Any) {
        
        if((sender as AnyObject).selectedSegmentIndex == 0){
            UIView.animate(withDuration: 0.5, animations: { 
                
                self.tweetsContainer.alpha = 1
                self.mediaContainer.alpha = 0
                self.likesContainer.alpha = 0
            })
        } else if((sender as AnyObject).selectedSegmentIndex == 1){
            UIView.animate(withDuration: 0.5, animations: {
                
                self.tweetsContainer.alpha = 0
                self.mediaContainer.alpha = 1
                self.likesContainer.alpha = 0
                
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                
                self.tweetsContainer.alpha = 0
                self.mediaContainer.alpha = 0
                self.likesContainer.alpha = 1
            })
        }
        
    }
    
    @IBAction func profilePictureTapped(_ sender: UITapGestureRecognizer) {
        
        // crate the action sheet
        let myActionSheet = UIAlertController(title: "Profile Picture", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let viewPicture = UIAlertAction(title: "View Picture", style: UIAlertActionStyle.default) { (action) in
            
            //ここから
        }
        
    }
    
    
}
