//
//  Room.swift
//  GameStart
//
//  Created by 김민국 on 2018. 7. 4..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import Foundation

struct Room {
    var RoomName: String
    var UserName: [String]
    var ToName: String
    var text: [AnyObject]
    var haveLog: Bool
    
    init(roomname: String, username: [String], log: [AnyObject], To: String, have: Bool) {
        self.RoomName = roomname
        self.UserName = username
        self.text = log
        self.ToName = To
        self.haveLog = have
    }
}
