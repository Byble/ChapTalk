//
//  ChatRoom.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 25..
//  Copyright © 2018년 MGHouse. All rights reserved.
//
// #0: > Message
// #4Hello > say hello to client from server at first time
// #5request friend
import UIKit

protocol ClientDelegate: class {
    func receivedMessage(message: Message)
}

class Client: NSObject {

    weak var delegate: ClientDelegate?
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    //let host: CFString = "127.0.0.1" as CFString
    
    let host: CFString = "169.254.80.148" as CFString
    let port: UInt32 = 34730
    let maxReadLength = 1024
    
    var username = "default"
    
    func setupNetwork() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: .main, forMode: .commonModes)
        outputStream.schedule(in: .main, forMode: .commonModes)
        
        inputStream.open()
        outputStream.open()
        
    }
    
    func sendMessage(message: String){
        let data = "#0:\(username):\(message)".data(using: .utf8)!
        _ = data.withUnsafeBytes{outputStream.write($0, maxLength: data.count)}
    }
    
    func requestFriend(name: String){
        let data = "#5:\(name)".data(using: .utf8)!
        _ = data.withUnsafeBytes{outputStream.write($0, maxLength: data.count)}
    }
    func gameStartMsg(myName: String, enemyName: String){
        let data = "#6:\(myName):\(enemyName)".data(using: .utf8)!
        _ = data.withUnsafeBytes{outputStream.write($0, maxLength: data.count)}
    }
    func goGameMsg(){
        let data = "#7:start".data(using: .utf8)!
        _ = data.withUnsafeBytes{outputStream.write($0, maxLength: data.count)}
    }
    func sendID(){
        let data = "\(username)".data(using: .utf8)! // #: ID 전송
        _ = data.withUnsafeBytes{outputStream.write($0, maxLength: data.count)}
    }
    func myChar(text: String){
        let data = "#8:\(username):\(text)".data(using: .utf8)!
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
                                       encoding: .utf8,
                                       freeWhenDone: true)?.components(separatedBy: ":"),
            let name = stringArray.first,
            let message = stringArray.last else {
                return nil
        }

        return Message(message: message, username: name)
    }
}
extension Client: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if aStream == inputStream{
            switch eventCode{
            case Stream.Event.errorOccurred:
                print("오류 발생")
            case Stream.Event.openCompleted:
                print("openCompleted")
            case Stream.Event.hasBytesAvailable:
                print("HasBytesAvaliable")
                readAvailableBytes(stream: aStream as! InputStream)
            case Stream.Event.endEncountered:
                stopChatSession()
            default:
                print("inputStream default")
                break
            }
        }
        if aStream == outputStream{
            switch eventCode{
            case Stream.Event.errorOccurred:
                print("오류 발생")
            case Stream.Event.openCompleted:
                print("openCompleted")
            case Stream.Event.hasSpaceAvailable:
                print("HasSpaceAvailable")
            case Stream.Event.endEncountered:
                stopChatSession()
            default:
                print("outputStream default")
                break;
            }
        }
    }
}
