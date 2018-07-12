//
//  ChatViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 26..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit
import SwiftyJSON
import SpriteKit

protocol sendRoomDelegate {
    func sendRoomInform(room: Room, name: String)
}

class ChatViewController: UIViewController, UITextFieldDelegate {

    var delegate: sendRoomDelegate?
    
    var client: Client?
    var RoomInform: Room!
    
    var textArr = [[String:String]]()
    var text = [String:String]()
    
    @IBOutlet var chatView: UIView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var SKViewBottom: NSLayoutConstraint!
    
    var sendBtn: UIButton!
    var textView: UITextField! = nil
    let originBottom = 34
    let SKViewOriginBottom = 78
    
    let now = NSDate()
    
    //GameScene -- START
    @IBOutlet var SpritekitView: SKView!
    private var sceneView: SKScene?
    private var gameScene: GameScene?
    
    var startBtn: UIButton?
    var cancelBtn: UIButton?
    var GameStartBtn: UIButton?
    var isGameON: Bool = false
    var forceSend: Bool = false //when get question make it false
    let WhatAmI = ["my","enemy"]
    var IAM: String = ""
    //GameScene -- END
    var count = 10
    var timer: Timer?
    var timeView: UILabel?
    
    override func viewWillAppear(_ animated: Bool) {
        
        addView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client?.delegate = self
        addNotification()
        
        self.view.isUserInteractionEnabled = false
        normalView()
    }

    func normalView(){
        if let kitview = SpritekitView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "NormalScene") {
                // Set the scale mode to scale to fit the window
                // Present the scene
                kitview.presentScene(scene)
                
                self.view.isUserInteractionEnabled = true
            }
        }
        
    }
    
    @objc func backTouched(){
        RoomInform.haveLog = true
        delegate?.sendRoomInform(room: RoomInform, name: RoomInform.ToName)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func gameViewBtn(){
        startBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        startBtn?.backgroundColor = UIColor.red
        startBtn?.setTitle("게임시작", for: .normal)
        startBtn?.center.y = self.view.center.y
        startBtn?.center.x = self.view.center.x - 75
        startBtn?.addTarget(self, action: #selector(GameStart), for: .touchUpInside)
        
        cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        cancelBtn?.backgroundColor = UIColor.blue
        cancelBtn?.setTitle("취소", for: .normal)
        cancelBtn?.center.y = self.view.center.y
        cancelBtn?.center.x = self.view.center.x + 75
        cancelBtn?.addTarget(self, action: #selector(CancelBtn), for: .touchUpInside)
    
        self.view.addSubview(startBtn!)
        self.view.addSubview(cancelBtn!)
    }
    @objc func GameAllStart(){
        textView.isUserInteractionEnabled = true
        client?.goGameMsg()
        GameStartBtn?.isUserInteractionEnabled = false
    }
    @objc func GameStart(){
        if let view = SpritekitView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.textView.isUserInteractionEnabled = false
                self.client?.gameStartMsg(myName: (self.client?.username)!, enemyName: self.RoomInform.ToName)
            })
        }
        
    }
    @objc func CancelBtn(){
        startBtn?.removeFromSuperview()
        cancelBtn?.removeFromSuperview()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textView{
            
            if isGameON == true{
                if forceSend != true{
                    if let game = SpritekitView.scene as? GameScene{
                        if IAM == WhatAmI[0]{//our
                            game.selectMyCharacter(text: textField.text!)
                            if(textView.text?.count == 0){
                                client?.myChar(text: "no")
                            }else{
                                client?.myChar(text: textView.text!)
                            }
                            textView.text = ""
                            textView.resignFirstResponder()
                            sendBtn.isHidden = true
                            
                            self.stopTimer()
                        }else{//enemy
                            game.selectEnemyCharacter(text: textField.text!)
                            
                            if(textView.text?.count == 0){
                                client?.myChar(text: "no")
                            }else{
                                client?.myChar(text: textView.text!)
                            }
                            textView.text = ""
                            textView.resignFirstResponder()
                            sendBtn.isHidden = true
                            
                            self.stopTimer()
                        }
                    }
                }
            }else{
                chatViewReturn()
            }
        }
        return true
    }
    @objc func chatViewReturn(){
        client?.sendMessage(message: textView.text!)
        if let game = SpritekitView.scene as? NormalScene{
            game.MyCharacterSend()
        }
        //JSON 저장
        text["roomName"] = RoomInform.RoomName
        text["userName"] = client?.username
        text["time"] = "\(self.getCurrentTime(dateToConvert: now))"
        text["chat"] = textView.text!
        textArr.append(text)
        jsonMake(Arr: textArr)
        
        textView.text = ""
        textView.resignFirstResponder()
        sendBtn.isHidden = true
    }
    func startTimer(){
        timeView = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        timeView?.center.x = self.view.center.x
        timeView?.center.y = self.view.center.y * 0.7
        self.view.addSubview(timeView!)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        count = 10
    }
    
    @objc func update(){
        //0.5초마다 반복
        
        timeView?.text = String(count)
        
        if(count < 1){
            
            self.stopTimer()
            if isGameON == true{
                if let game = SpritekitView.scene as? GameScene{
                    if IAM == WhatAmI[0]{//our
                        game.selectMyCharacter(text: textView.text!)
                        
                        if(textView.text?.count == 0){
                            client?.myChar(text: "no")
                        }else{
                            client?.myChar(text: textView.text!)
                        }
                        textView.text = ""
                        textView.resignFirstResponder()
                        sendBtn.isHidden = true
                        forceSend = true
                        
                    }else{//enemy
                        game.selectEnemyCharacter(text: textView.text!)
                        
                        if(textView.text?.count == 0){
                            client?.myChar(text: "no")
                        }else{
                            client?.myChar(text: textView.text!)
                        }
                        textView.text = ""
                        textView.resignFirstResponder()
                        sendBtn.isHidden = true
                        forceSend = true
                        
                    }
                }
            }
        }
        count = count-1
    }
    func stopTimer(){
        self.timer?.invalidate()
        self.timer = nil
        self.timeView?.text = ""
        self.timeView?.removeFromSuperview()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if !(textField.text?.isEmpty)!{
            sendBtn.isHidden = false
        }else{
            sendBtn.isHidden = true
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeNotification()
    }
}

extension ChatViewController{
    func addView(){

        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        let backBtn: UIButton = UIButton.init(type: .custom)
        backBtn.setBackgroundImage(UIImage(named: "back1.png"), for: .normal)
        backBtn.addTarget(self, action: #selector(backTouched), for: .touchUpInside)
        backBtn.widthAnchor.constraint(equalToConstant: 21).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        let leftBarBtn = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = leftBarBtn
        
        chatView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        let plustBtn = UIButton(frame: CGRect(x: 0, y: 0, width: chatView.frame.height*0.45, height: chatView.frame.height*0.45))
        plustBtn.center = CGPoint(x: chatView.frame.height*0.5, y: chatView.frame.height/2)
        
        plustBtn.borderColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1)
        plustBtn.borderWidth = 2
        plustBtn.layer.cornerRadius = plustBtn.frame.height/4
        plustBtn.addTarget(self, action: #selector(gameViewBtn), for: .touchUpInside)
        chatView.addSubview(plustBtn)
        
        
        textView = UITextField(frame: CGRect(x: 0, y: 0, width: chatView.frame.width*0.85, height: chatView.frame.height*0.75))
        textView.center = CGPoint(x: chatView.frame.width/2 + chatView.frame.height*0.35, y: chatView.frame.height/2)
        textView.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
        textView.clipsToBounds = true
        textView.layer.cornerRadius = textView.frame.height/2
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.autocapitalizationType = .none
        textView.returnKeyType = .send
        textView.keyboardType = .asciiCapable
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textView.frame.height))
        textView.leftView = padding
        textView.leftViewMode = .always
        chatView.addSubview(textView)
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: textView.frame.height, height: textView.frame.height))
        
        sendBtn = UIButton(frame: CGRect(x: 0, y: 0, width: textView.frame.height*0.85, height: textView.frame.height * 0.85))
        sendBtn.layer.borderWidth = 2
        sendBtn.layer.borderColor = UIColor.yellow.cgColor
        sendBtn.backgroundColor = UIColor.brown
        sendBtn.layer.cornerRadius = sendBtn.frame.width/2
        sendBtn.clipsToBounds = true
        sendBtn.center = rightPadding.center
        sendBtn.isHidden = true
        sendBtn.addTarget(self, action: #selector(chatViewReturn), for: .touchUpInside)
        rightPadding.addSubview(sendBtn)
        
        textView.rightView = rightPadding
        textView.rightViewMode = .always
        textView.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textView.delegate = self
        
        navigationItem.title = RoomInform.ToName
    }

    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func removeNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification){
        if let userInfo = notification.userInfo as? Dictionary<String,AnyObject>{
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]
            let keyboardRect = frame?.cgRectValue
            if let keyboardHeight = keyboardRect?.height{
                self.bottomConstraint.constant = keyboardHeight
                self.SKViewBottom.constant = keyboardHeight
            }
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(notification: Notification){
        self.bottomConstraint.constant = CGFloat(originBottom)
        self.SKViewBottom.constant = CGFloat(SKViewOriginBottom)
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
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
}

extension ChatViewController{
    func jsonRead() -> [[String:String]]{
        let filemanager = FileManager.default
        let url = try? filemanager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let jsonUrl = url?.appendingPathComponent("\(RoomInform.RoomName).json")
        let jsonReadData = NSData(contentsOf: jsonUrl!)
        if let jsonReadData = jsonReadData{
            let parse = try? JSONSerialization.jsonObject(with: jsonReadData as Data, options: .mutableContainers)
            let datas = parse as! [[String:String]]
//            for data in datas{
//                print(data["userName"] as! String)
//            }
            return datas
        }else{
            return [[String:String]]()
        }
    }
    func jsonMake(Arr: [[String:String]]){
        let jsonData = try? JSONSerialization.data(withJSONObject: Arr, options: .prettyPrinted)
        
        let filemanager = FileManager.default
        var isDirectory: ObjCBool = false
        
        let url = try? filemanager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let jsonUrl = url?.appendingPathComponent("\(RoomInform.RoomName).json")
        
        if !filemanager.fileExists(atPath: (jsonUrl?.path)!, isDirectory: &isDirectory){
            let created = filemanager.createFile(atPath: (jsonUrl?.path)!, contents: nil, attributes: nil)
            if created{
                print("file created")
                try? jsonData?.write(to: jsonUrl!)
            }else{
                print("can't create")
            }
        }else{
            print("already exists")
            try? jsonData?.write(to: jsonUrl!)
            
        }
    }
}

extension ChatViewController: ClientDelegate {
    func receivedMessage(message: Message) {
        
        if (message.senderUsername == "#1"){
            
            let splitMessge = message.message.components(separatedBy: "/")
            let senderName = splitMessge[0]
            let mess = splitMessge[1]
            if senderName != client?.username{
                if let game = SpritekitView.scene as? NormalScene{
                    game.addText(text: "From: \(senderName)\n\(mess)")
                }
            }
        }
        if (message.senderUsername == "#6"){
            startBtn?.removeFromSuperview()
            cancelBtn?.removeFromSuperview()
            let splieMessage = message.message.components(separatedBy: "/")
            let first = splieMessage[0]
            let second = splieMessage[1]

            if client?.username == first{
                IAM = WhatAmI[0]
                GameStartBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
                GameStartBtn?.setTitle("게임 시작", for: .normal)
                GameStartBtn?.backgroundColor = UIColor.lightGray
                GameStartBtn?.center = self.view.center
                GameStartBtn?.addTarget(self, action: #selector(GameAllStart), for: .touchUpInside)
                self.view.addSubview(GameStartBtn!)
            }else if(client?.username == second){
                IAM = WhatAmI[1]
            }
            isGameON = true
        }
        if (message.senderUsername == "#7"){
            GameStartBtn?.removeFromSuperview()
            let question = message.message

            if let game = SpritekitView.scene as? GameScene{
                game.ImReady = false
                game.EnemyReady = false
                game.questionCreate(index: Int(question)!)
                startTimer()
            }
        }
        if (message.senderUsername == "#8"){
            let splitMessage = message.message.components(separatedBy: "/")
            let username = splitMessage[0]
            let text = splitMessage[1]
            if client?.username != username{
                if let game = SpritekitView.scene as? GameScene{
                    if IAM == WhatAmI[0]{
                        game.selectEnemyCharacter(text: text)
                        game.IAM = WhatAmI[1]
                    }else if (IAM == WhatAmI[1]){
                        game.selectMyCharacter(text: text)
                        game.IAM = WhatAmI[0]
                    }
                }
            }
        }
    }
}
