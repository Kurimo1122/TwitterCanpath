//
//  ViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2016/12/26.
//  Copyright © 2016 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
        
            if let currentUser = user {
                
                print("user is signed in")
                
                // send the user to the homeviewcontroller
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarControllerView")
                
                // send the user to the homescreen
                self.present(homeViewController, animated: true, completion: nil)
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

