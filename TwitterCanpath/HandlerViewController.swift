//
//  HandlerViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2016/12/26.
//  Copyright © 2016 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HandlerViewController: UIViewController {
    
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var handleId: UITextField!
    @IBOutlet weak var startTweeting: UIBarButtonItem!
    @IBOutlet weak var errorMessage: UILabel!
    
    var user: AnyObject?
    
    var rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = FIRAuth.auth()?.currentUser

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startTweetingTapped(_ sender: Any) {
        
        let handle = rootRef.child("handles").child(handleId.text!).observe(.value) { (snapshot: FIRDataSnapshot) in
            
            if (!snapshot.exists()) {
                // update the handle in the user_profiles and in the handles node
                self.rootRef.child("user_profiles").child(self.user!.uid).child("handle").setValue(self.handleId.text!.lowercased())
                
                // update the name of the user
                
                self.rootRef.child("user_profiles").child(self.user!.uid).child("name").setValue(self.fullName.text!)
                
                // update the handle in the handle node
                self.rootRef.child("handles").child(self.handleId.text!.lowercased()).setValue(self.user!.uid)
                
                // send the user to home screen
                
                
            } else {
                self.errorMessage.text! = "このIDはすでに使われています。"
            }
        }
        
    }

}
