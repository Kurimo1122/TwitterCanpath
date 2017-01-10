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
import FirebaseStorage

class NewTweetViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var newTweetTextView: UITextView!
    @IBOutlet weak var newTweetToolbar: UIToolbar!
    
    @IBOutlet weak var toolbarBottomConstraints: NSLayoutConstraint!
    var toolbarBottomConstraintInitialValue: CGFloat?
    
    // Create a reference to the database
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newTweetToolbar.isHidden = true
        
        // If you don't write this line, you get nothing when text view begins editing
        self.newTweetTextView.delegate = self
        
        loggedInUser = FIRAuth.auth()?.currentUser
        
        self.newTweetTextView.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        //self.newTweetTextView.text = "いま何してる？"
        self.newTweetTextView.textColor = UIColor.black

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        enableKeyboardHideOnTap()
        
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraints.constant
    }
    
    
    private func enableKeyboardHideOnTap(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewTweetViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewTweetViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewTweetViewController.hideKeyboard))
        
        self.view.addGestureRecognizer(tap)
        
    }
    
    func keyboardWillShow(_ notification: Notification)
    {
        let info = (notification as NSNotification).userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.toolbarBottomConstraints.constant = keyboardFrame.size.height
            
            self.newTweetToolbar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(_ notification: Notification)
    {
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            
            self.toolbarBottomConstraints.constant = self.toolbarBottomConstraintInitialValue!
            
            self.newTweetToolbar.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        /*
        if (self.newTweetTextView.textColor == UIColor.lightGray){
            self.newTweetTextView.text = ""
            self.newTweetTextView.textColor = UIColor.black
        }*/
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    
    @IBAction func didTapTweet(_ sender: Any) {
        
        var imagesArray = [AnyObject?]()
        
        self.newTweetTextView.attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, self.newTweetTextView.text.characters.count), options: []) { (value, range, true) in
            
            if (value is NSTextAttachment){
                let attachment = value as! NSTextAttachment
                var image: UIImage? = nil
                
                if (attachment.image != nil){
                    image = attachment.image!
                    imagesArray.append(image!)
                } else {
                    print("No image found")
                }
            }
        }
        
        let tweetLength = newTweetTextView.text.characters.count
        let numImages = imagesArray.count
        
        let storageRef = FIRStorage.storage().reference()
        
        
        let pictureStrorageRef = storageRef.child("user_profiles").child(self.loggedInUser!.uid).child("media")
        
        
        // below line occurs Index out of range error!!!
        //let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
        
        
        if (tweetLength > 0 && numImages > 0){
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            let uploadTask = pictureStrorageRef.put(lowResImageData!, metadata: nil, completion: { (metadata, error) in
                
                if (error == nil){
                    let downloadUrl = metadata!.downloadURL()
                    
                    let tweet = ["text": self.newTweetTextView.text, "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970)), "picture": downloadUrl!.absoluteString] as [String: Any]
                    
                    self.databaseRef.child("tweets").child(self.loggedInUser!.uid).childByAutoId().setValue(tweet)
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            dismiss(animated: true, completion: nil)
            
        } else if (tweetLength > 0) {
            
            print("--------------------------------------------------")
            print("To find out the tweet exists")
            print("--------------------------------------------------")
            
            let tweet = ["text": newTweetTextView.text, "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970)), "picture": ""] as [String: Any]
            
            //self.databaseRef.updateChildValues(childUpdates)
            self.databaseRef.child("tweets").child(self.loggedInUser!.uid).childByAutoId().setValue(tweet)
            
            dismiss(animated: true, completion: nil)
            
        } else if (numImages > 0){
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
            let uploadTask = pictureStrorageRef.put(lowResImageData!, metadata: nil, completion: { (metadata, error) in
                
                if (error == nil){
                    let downloadUrl = metadata!.downloadURL()
                    
                    let tweet = ["text": self.newTweetTextView.text, "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970)), "picture": downloadUrl!.absoluteString] as [String: Any]
                    
                    self.databaseRef.child("tweets").child(self.loggedInUser!.uid).childByAutoId().setValue(tweet)
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            dismiss(animated: true, completion: nil)
        }
    }

    /*
    @IBAction func tweetTapped(_ sender: Any) {
 
        var imagesArray = [AnyObject?]()
 
        self.newTweetTextView.attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, self.newTweetTextView.text.characters.count), options: []) { (value, range, true) in
            
            if (value is NSTextAttachment){
                let attachment = value as! NSTextAttachment
                var image: UIImage? = nil
                
                if (attachment.image != nil){
                    image = attachment.image!
                    imagesArray.append(image!)
                } else {
                    print("No image found")
                }
            }
        }
        
        let tweetLength = newTweetTextView.text.characters.count
        let numImages = imagesArray.count
        
        let storageRef = FIRStorage.storage().reference()
        let pictureStrorageRef = storageRef.child("user_profiles").child(self.loggedInUser!.uid).child("media")
        
        let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)
        
        if (tweetLength > 0 && numImages > 0){
            let uploadTask = pictureStrorageRef.put(lowResImageData!, metadata: nil, completion: { (metadata, error) in
                
                if (error == nil){
                    let downloadUrl = metadata!.downloadURL()
                    
                    let tweet = ["text": self.newTweetTextView.text, "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970)), "picture": downloadUrl!.absoluteString] as [String: Any]
                    
                    self.databaseRef.child("tweets").child(self.loggedInUser!.uid).childByAutoId().setValue(tweet)
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            dismiss(animated: true, completion: nil)
            
        } else if (tweetLength > 0) {
            
            let tweet = ["text": newTweetTextView.text, "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970))] as [String: Any]
            
            //self.databaseRef.updateChildValues(childUpdates)
            self.databaseRef.child("tweets").child(self.loggedInUser!.uid).childByAutoId().setValue(tweet)
            
            dismiss(animated: true, completion: nil)
            
        } else if (numImages > 0){
            
            let uploadTask = pictureStrorageRef.put(lowResImageData!, metadata: nil, completion: { (metadata, error) in
                
                if (error == nil){
                    let downloadUrl = metadata!.downloadURL()
                    
                    let tweet = ["text": self.newTweetTextView.text, "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970)), "picture": downloadUrl!.absoluteString] as [String: Any]
                    
                    self.databaseRef.child("tweets").child(self.loggedInUser!.uid).childByAutoId().setValue(tweet)
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            dismiss(animated: true, completion: nil)
        }
     
        /*
        if(newTweetTextView.text.characters.count > 0){
            //let key = databaseRef.child("tweets").childByAutoId().key
            
            //let childUpdates = ["/tweets/\(self.loggedInUser!.uid)/(key)text": newTweetTextView.text,
            //                    "/tweets/\(self.loggedInUser!.uid)/(key)timestamp": "\(NSDate().timeIntervalSince1970)"] as [String : Any]
            
            //let childUpdates = ["/tweets/\(self.loggedInUser!.uid)/(key)text": newTweetTextView.text,
            //                    "/tweets/\(self.loggedInUser!.uid)/(key)timestamp": "\(NSDate().timeIntervalSince1970)"] as [String : Any]
            
            let tweet = ["text": newTweetTextView.text, "timestamp": NSNumber(value: Int(Date().timeIntervalSince1970))] as [String: Any]
            
            //self.databaseRef.updateChildValues(childUpdates)
            self.databaseRef.child("tweets").child(self.loggedInUser!.uid).childByAutoId().setValue(tweet)
            
            dismiss(animated: true, completion: nil)
        }*/
    } */
    
    
    @IBAction func selectImageFromPhotos(_ sender: Any) {
        
        if (UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)){
            
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        var attributedString = NSMutableAttributedString()
        
        if(self.newTweetTextView.text.characters.count>0)
        {
            attributedString = NSMutableAttributedString(string:self.newTweetTextView.text)
        }
        else
        {
            attributedString = NSMutableAttributedString(string:"いま何してる？")
        }
        
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = image
        
        let oldWidth:CGFloat = textAttachment.image!.size.width
        
        let scaleFactor:CGFloat = oldWidth/(newTweetTextView.frame.size.width-50)
        
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        attributedString.append(attrStringWithImage)
        
        newTweetTextView.attributedText = attributedString
        dismiss(animated: true, completion: nil)
        
    }
    
}
