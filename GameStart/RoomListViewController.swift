//
//  ViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 25..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

class RoomListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableTopConstraint: NSLayoutConstraint!
    
    var client: Client?
    var Rooms = [String:Room]()
    var selectedRoom: Room!
    var selectedRoomUser: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIApplication.shared.delegate?.window??.rootViewController = segue.destination as? UITabBarController
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        

        client?.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        navigationItem.title = "채팅"
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 50/255, green: 30/255, blue: 20/255, alpha: 1)
    }
    
    func getCurrentTime(dateToConvert: NSDate) -> String{
        let objDateformat = DateFormatter()
        objDateformat.dateFormat = "yyyy-MM-dd"
        let strTime: String = objDateformat.string(from: dateToConvert as Date)
        let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
        let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
        let strTimeStamp: String = "\(milliseconds)"
        return strTimeStamp
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatFromList"{
            let navVC = segue.destination as? UINavigationController
            let chatVC = navVC?.topViewController as! ChatViewController
            chatVC.client = client
            chatVC.RoomInform = selectedRoom
            chatVC.delegate = self
        }
        if segue.identifier == "toChat"{
            let navVC = segue.destination as? UINavigationController
            let chatVC = navVC?.topViewController as! ChatViewController
            chatVC.client = client
            chatVC.RoomInform = Rooms[selectedRoomUser]
            chatVC.delegate = self
        }
    }
    
}

extension RoomListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "room"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
//        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "room")! as UITableViewCell
        cell.selectionStyle = .none

        if (Rooms.count != 0){
            if Array(Rooms)[indexPath.row].value.haveLog == true {
                cell.textLabel?.text = Array(Rooms)[indexPath.row].key
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 화면 이동
        selectedRoom = Array(Rooms)[indexPath.row].value
        performSegue(withIdentifier: "toChatFromList", sender: nil)
    }
}

extension RoomListViewController: ClientDelegate {
    func receivedMessage(message: Message) {
        if (message.senderUsername == "#1"){
            
            let splitMessge = message.message.components(separatedBy: "/")
            let senderName = splitMessge[0]
            let mess = splitMessge[1]

            if senderName != client?.username{
                if Rooms.keys.contains(senderName){
                }else{
                    let room = Room.init(roomname: senderName, username: [(client?.username)!, senderName], log: [], To: senderName, have: true)
                    Rooms.updateValue(room, forKey: senderName)
                    tableView.reloadData()
                }
            }else{
                print("==")
            }
        }
    }
}
extension RoomListViewController: sendRoomDelegate{
    func sendRoomInform(room: Room, name: String) {
        Rooms.updateValue(room, forKey: name)
        tableView.reloadData()
    }
}
