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

class MeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tweetsContainer: UIView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var likesContainer: UIView!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var about: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    
    @IBOutlet var testRecognizer: UITapGestureRecognizer!
    
    
    var loggedInUser: AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(testRecognizerTapped))
        //tapGesture.delegate = self
        //self.view.addGestureRecognizer(tapGesture)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)


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
    
    
    
    
    @IBAction func testRecognizerTapped(_ sender: UITapGestureRecognizer) {
        print("testRecognizer is working!")
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
        
        
        print("hey")
        
        // crate the action sheet
        let myActionSheet = UIAlertController(title: "Profile Picture", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let viewPicture = UIAlertAction(title: "View Picture", style: UIAlertActionStyle.default) { (action) in
            
            //ここから
            //let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: self.profilePicture.image)
            
            newImageView.frame = self.view.frame
            
            newImageView.backgroundColor = UIColor.black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
            
            tap.delegate = self;
            
            newImageView.addGestureRecognizer(tap)
 
            self.view.addSubview(newImageView)
            
        }
        
        let photoGallery = UIAlertAction(title: "Photos", style: UIAlertActionStyle.default) { (action) in
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default){ (action) in
            
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
        
    }
    
    func dismissFullScreenImage(sender: UITapGestureRecognizer) {
        
        //remove the larger image from the view
        sender.view?.removeFromSuperview()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        profilePicture.image = image
        
        self.imageLoader.startAnimating()
        
        
        if let imageData = UIImagePNGRepresentation(self.profilePicture.image!)! as Data?{
            
            let profilePicStorageRef = storageRef.child("user_profiles").child(self.loggedInUser!.uid).child("profile_pic")
            
            let uploadTask = profilePicStorageRef.put(imageData, metadata: nil, completion: { (metadata, error) in
                
                if (error == nil) {
                    let downloadUrl = metadata!.downloadURL()
                    
                    self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).child("profile_pic").setValue(downloadUrl!.absoluteString)
                } else {
                    print(error?.localizedDescription)
                }
            })
            
            self.imageLoader.stopAnimating()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func aboutDidEndEditing(_ sender: Any) {
        
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).child("about").setValue(self.about.text)
    }
    
}
