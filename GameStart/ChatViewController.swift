//
//  ChatViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 26..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    var client: Client? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InsertRoom"{
            let viewController: RoomListViewController = segue.destination as! RoomListViewController
            viewController.delegate = self
        }
    }
}

extension ChatViewController: SendDataDelegate{
    func sendData(Sclient: Client) {
        client = Sclient
    }
}
