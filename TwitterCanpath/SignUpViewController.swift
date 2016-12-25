//
//  SignUpViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2016/12/26.
//  Copyright © 2016 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signup: UIBarButtonItem!
    @IBOutlet weak var errorMessage: UILabel!
    
    var databaseRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signup.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signupTapped(_ sender: Any) {
        
        signup.isEnabled = false
        
        FIRAuth.auth()?.createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            
            if (error != nil){
                
                if (error!._code == 17999){
                    self.errorMessage.text! = "無効なメールアドレスです。"
                } else {
                    self.errorMessage.text! = error!.localizedDescription
                }
                
            } else {
                self.errorMessage.text! = "新規登録に成功しました！"
                
                FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                    
                    if (error == nil) {
                        self.databaseRef.child("user_profiles").child(user!.uid).child("email").setValue(self.email.text!)
                        
                        self.performSegue(withIdentifier: "HandleViewSegue", sender: nil)
                    }
                })
            }
        })
        
    }
    

    @IBAction func mailTextChanged(_ sender: UITextField) {
        if(email.text!.characters.count > 0 &&
            password.text!.characters.count > 0)
        {
            signup.isEnabled = true
        } else {
            signup.isEnabled = false
        }
    }
}
