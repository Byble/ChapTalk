//
//  ChatRoom.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 25..
//  Copyright © 2018년 MGHouse. All rights reserved.
//
// #0: > Message
// #1: > makeRoom
// #2: > joinRoom
// #3require > require updateRoomList
// #3response > get updatedRoomList
// #4Hello > say hello to client from server at first time

import UIKit

protocol ClientDelegate: class {
    func receivedMessage(message: Message)
}

class Client: NSObject {

    weak var delegate: ClientDelegate?
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    let host: CFString = "127.0.0.1" as CFString
    let port: UInt32 = 34730
    let maxReadLength = 1024
    
    var username = ""
    
    func setupNetwork() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.open()
        outputStream.open()
    }
    
    func sendMessage(message: String){
        let data = "#0:\(username): \(message)".data(using: .ascii)! // #0:username: message 메시지 보내기 요청
        _ = data.withUnsafeBytes{outputStream.write($0, maxLength: data.count)}
    }
    
    func MakeRoom(roomName: String) {
        let data = "#1:\(username):name:\(roomName)".data(using: .ascii)! // #1:username:name:roomName 방 만들기 요청
        _ = data.withUnsafeBytes{ outputStream.write($0, maxLength: data.count)}
    }
    
    func JoinRoom(roomName: String) {
        let data = "#2:\(username):To:\(roomName)".data(using: .ascii)! // #2:username:To:roomName 방 들어가기 요청
        _ = data.withUnsafeBytes{ outputStream.write($0, maxLength: data.count)}
    }
    
    func updateRoomList(){
        let data = "#3:require:\(username))".data(using: .ascii)! // #3:require: username 방 리스트 요청
        _ = data.withUnsafeBytes{outputStream.write($0, maxLength: data.count)}
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = inputStream.streamError {
                    break
                }
            }
            
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                delegate?.receivedMessage(message: message)
            }
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> Message? {
        guard let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .ascii,
                                       freeWhenDone: true)?.components(separatedBy: ":"),
            let name = stringArray.first,
            let message = stringArray.last else {
                return nil
        }
        
        let messageSender:MessageSender = (name == self.username) ? .ourself : .someoneElse
        
        return Message(message: message, messageSender: messageSender, username: name)
    }
}
extension Client: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("새 메시지 도착")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            stopChatSession()
        case Stream.Event.errorOccurred:
            print("오류 발생")
        case Stream.Event.hasSpaceAvailable:
            print("공간 부족")
        default:
            print("Something Event...")
            break
        }
    }
}
