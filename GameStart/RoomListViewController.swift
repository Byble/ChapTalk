//
//  ViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 25..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

protocol SendDataToChatDelegate{
    func sendData(Sclient: Client)
}

class RoomListViewController: UIViewController {
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableTopConstraint: NSLayoutConstraint!
    
    var delegate: SendDataToChatDelegate!
    
    var client: Client?
    var Rooms: [String] = ["Hello World"]
    
    var minValue = 0
    var maxValue = 100
    var timer = Timer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        client?.delegate = self
        client?.setupNetwork()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(displayP3Red: 250/255, green: 250/255, blue: 250/255, alpha: 1.0)
        
        progressView.alpha = 0
    }
    
    
    @IBAction func updateRoomList(_ sender: Any) {
        self.showProgressBar()
        tableView.beginUpdates()
        
        client?.updateRoomList()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(progressUpper(_:)), userInfo: nil, repeats: true)
        progressView.setProgress(0, animated: false)

    }
    @objc func progressUpper(_ sender: Any){
        if minValue != maxValue{
            minValue += 1
            progressView.progress = Float(minValue) / Float(maxValue)
        }else{
            minValue = 0
            self.tableView.endUpdates()
            self.hideProgressBar()
        }
    }

    func showProgressBar()->Void {
        progressView.progress = 0
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.progressView.alpha = 1.0
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.tableTopConstraint.constant = 50
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func hideProgressBar()->Void {
        self.progressView.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            
            self.tableTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToRoom"{
            let viewController: LogInViewController = segue.destination as! LogInViewController
            viewController.delegate = self
        }
    }
}

extension RoomListViewController: ClientDelegate {
    func receivedMessage(message: Message) {
        if(message.senderUsername == "#3response"){
            Rooms = message.message.components(separatedBy: ",")
        }
    }
}

extension RoomListViewController: SendDataToRoomDelegate{
    func sendData(Sclient: Client) {
        client = Sclient
    }
}

extension RoomListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "message"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.selectionStyle = .none
        
        cell.textLabel?.text = Rooms[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        client?.JoinRoom(roomName: Rooms[indexPath.row])
        // 화면 이동
        delegate?.sendData(Sclient: client!)
        performSegue(withIdentifier: "JoinRoom", sender: nil)
    }
}



