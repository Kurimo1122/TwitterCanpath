//
//  NewTweetViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2017/01/05.
//  Copyright © 2017 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewTweetViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var newTweetTextView: UITextView!
    
    
    // Create a reference to the database
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If you don't write this line, you get nothing when text view begins editing
        self.newTweetTextView.delegate = self
        
        loggedInUser = FIRAuth.auth()?.currentUser
        
        newTweetTextView.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        newTweetTextView.text = "いま何してる？"
        newTweetTextView.textColor = UIColor.lightGray

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        newTweetTextView.text = ""
        newTweetTextView.textColor = UIColor.black
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func tweetTapped(_ sender: Any) {
        
        if(newTweetTextView.text.characters.count > 0){
            let key = databaseRef.child("tweets").childByAutoId().key
            
            let childUpdates = ["/tweets/\(self.loggedInUser!.uid)/(key)text": newTweetTextView.text,
                                "/tweets/\(self.loggedInUser!.uid)/(key)timestamp": "\(NSDate().timeIntervalSince1970)"] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            dismiss(animated: true, completion: nil)
        }
    }
    

}
