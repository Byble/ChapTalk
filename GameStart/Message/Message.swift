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
    
    init(message: String, username: String) {
        self.message = message
        self.senderUsername = username
    }
}
