//
//  HomeViewTableViewCell.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2017/01/04.
//  Copyright © 2017 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit

public class HomeViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var tweet: UITextView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //public func configure(profilePic: String?, name: String, handle: String, tweet: String){
    public func configure(profilePic: String?, name: String, handle: String, tweet: String){
        
        self.tweet.text = tweet
        self.handle.text = "@"+handle
        self.name.text = name
        
        if((profilePic) != nil){
            let imageData = try! Data(contentsOf: URL(string: profilePic!)!)
            
            self.profilePic.image = UIImage(data: imageData)
        } else {
            self.profilePic.image = UIImage(named: "twitter")
            
        }
    }

}
