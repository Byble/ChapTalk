//
//  FriendListTableViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 29..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

class FriendListTableViewController: UITableViewController, FriendDataDelegate {
    
    
    var client: Client?
    
    let sections = ["My","Friend"]
    var Friend: [String] = []
    
    var passName:String = ""
    
    @IBOutlet var addBtn: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        

        navigationItem.title = "친구"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 50/255, green: 30/255, blue: 20/255, alpha: 1)
        
        addBtn.tintColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabbar = self.tabBarController as! UITabBarController
        UIApplication.shared.delegate?.window??.rootViewController = tabbar
        
        client?.delegate = self
        
        client?.sendID()
    }
    func sendFriendData(name: String) {
        Friend.append(name)
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Friend.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "Friend"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.selectionStyle = .none
        if (Friend.count != 0){
            cell.textLabel?.text = Friend[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        passName = Friend[indexPath.row]
        performSegue(withIdentifier: "UserProfile", sender: self)
    }

    @IBAction func addFriend(_ sender: Any) {
        performSegue(withIdentifier: "FriendFind", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "UserProfile"){
            let profileVC = segue.destination as! ProfileViewController
            profileVC.name = passName
            profileVC.client = client
        }
        if (segue.identifier == "FriendFind"){
            let navVC = segue.destination as! UINavigationController
            let findVC = navVC.topViewController as! FriendFindViewController
            findVC.client = client
            findVC.delegate = self
        }
    }
}

extension FriendListTableViewController: ClientDelegate {
    func receivedMessage(message: Message) {
        
    }
}
