//
//  Message.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 25..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import Foundation


struct Message {
    let message: String
    let senderUsername: String
    let messageSender: MessageSender
    
    init(message: String, messageSender: MessageSender, username: String) {
        self.message = ""
        self.messageSender = messageSender
        self.senderUsername = username
    }
}
