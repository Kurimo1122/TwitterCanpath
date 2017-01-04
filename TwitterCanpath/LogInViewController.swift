//
//  LogInViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2016/12/26.
//  Copyright © 2016 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LogInViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func loginTapped(_ sender: Any) {
        
        FIRAuth.auth()?.signIn(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            
            if (error == nil)
            {
                self.rootRef.child("user_profiles").child((user?.uid)!).child("handle").observe(.value) { (snapshot: FIRDataSnapshot) in
                    
                    if(!snapshot.exists()){
                        // user does not have a handle
                        // send the user to the handleView
                        
                        self.performSegue(withIdentifier: "HandleViewSegue", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "HomeViewSegue", sender: nil)
                    }
                }
            } else {
                self.errorMessage.text = error?.localizedDescription
            }
            
        })
    }
}
