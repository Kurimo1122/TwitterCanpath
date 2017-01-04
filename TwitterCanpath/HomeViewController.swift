//
//  HomeViewController.swift
//  TwitterCanpath
//
//  Created by Toshimitsu Kugimoto on 2017/01/04.
//  Copyright © 2017 Toshimitsu Kugimoto. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    func numberOfSections(in tableView: UITableView) -> Int {
        return 20
    }
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: HomeViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "homeViewTableViewCell", for: indexPath) as! HomeViewTableViewCell
        
        let cell = UITableViewCell()
        cell.textLabel?.text = "You have no snaps 😂"
        
        return cell
    }
    
}
