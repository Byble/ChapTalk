//
//  FriendFindViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 7. 2..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

protocol FriendDataDelegate{
    func sendFriendData(name: String)
}

import UIKit

class FriendFindViewController: UIViewController, UITextFieldDelegate {

    var foundName: String = ""
    
    var uisearch: UITextField!
    var client: Client?
    var delegate: FriendDataDelegate?
    var ProfileView: UIImageView!
    var nameLabel: UILabel!
    var addBtn: UIButton!
    var isInstalled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        client?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addView()
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (uisearch.text?.count)! != 0{
            client?.requestFriend(name: uisearch.text!)
            uisearch.resignFirstResponder()
        }
        
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @objc func backTouched(){
        dismiss(animated: true, completion: nil)
    }
    @objc func addFriend(){
        delegate?.sendFriendData(name: foundName)
        dismiss(animated: true, completion: nil)
    }
}

extension FriendFindViewController{
    func addView(){
        navigationItem.title = "친구 추가"
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 50/255, green: 30/255, blue: 20/255, alpha: 1)
        
        let backBtn: UIButton = UIButton.init(type: .custom)
        backBtn.setBackgroundImage(UIImage(named: "xBtn.png"), for: .normal)
        backBtn.addTarget(self, action: #selector(backTouched), for: .touchUpInside)
        backBtn.widthAnchor.constraint(equalToConstant: 21).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        let leftBarBtn = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = leftBarBtn
        
        self.view.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.title = "아이디 검색"
        
        uisearch = UITextField(frame: CGRect(x: 0, y: 110, width: self.view.frame.width * 0.95, height: 40))
        uisearch.delegate = self
        uisearch.center.x = view.center.x
        uisearch.placeholder = "친구의 아이디를 입력하세요"
        uisearch.returnKeyType = .search
        uisearch.autocorrectionType = .no
        uisearch.autocapitalizationType = .none
        uisearch.backgroundColor = UIColor.white
        uisearch.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
        uisearch.layer.borderWidth = 1
        uisearch.keyboardType = .asciiCapable
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: uisearch.frame.height))
        
        let searchBtn = UIImage(named: "search.png")
        let searchBtnView = UIImageView(image: searchBtn)
        searchBtnView.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        searchBtnView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        searchBtnView.contentMode = .scaleAspectFit
        searchBtnView.center = rightView.center
        rightView.addSubview(searchBtnView)
        
        uisearch.rightView = rightView
        uisearch.rightViewMode = .always
        
        let Lpad = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: uisearch.frame.height))
        uisearch.leftView = Lpad
        uisearch.leftViewMode = .always
        
        let sep = UIView(frame: CGRect(x: uisearch.frame.width - rightView.frame.width, y: 0, width: 1, height: uisearch.frame.height))
        sep.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        uisearch.addSubview(sep)
        
        view.addSubview(uisearch)
    }
    func FoundFriend(message: Message){
        if (isInstalled == true)
        {
            ProfileView.removeFromSuperview()
            nameLabel.removeFromSuperview()
            addBtn.removeFromSuperview()
            isInstalled = false
        }
        
        let Profileimage = UIImage(named: "profile.png")
        ProfileView = UIImageView(image: Profileimage)
        ProfileView.frame = CGRect(x: 0, y: 200, width: 120, height: 120)
        ProfileView.center.x = self.view.center.x
        ProfileView.layer.cornerRadius = ProfileView.frame.width/2
        ProfileView.clipsToBounds = true
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 325, width: 100, height: 30))
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.text = message.message
        nameLabel.isUserInteractionEnabled = false
        nameLabel.center.x = self.view.center.x
        nameLabel.textAlignment = .center
        foundName = message.message
        
        addBtn = UIButton(frame: CGRect(x: 0, y: 370, width: 125, height: 38))
        addBtn.center.x = self.view.center.x
        addBtn.setTitleColor(UIColor.black, for: .normal)
        addBtn.contentHorizontalAlignment = .center
        addBtn.contentVerticalAlignment = .center
        addBtn.titleLabel?.font = addBtn.titleLabel?.font.withSize(15)
        addBtn.backgroundColor = UIColor.yellow
        if message.message != client?.username{
            addBtn.setTitle("친구 추가", for: .normal)
            
            addBtn.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
        }else{
            addBtn.setTitle("나의 계정입니다.", for: .normal)
        }
        
        self.view.addSubview(ProfileView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(addBtn)
        isInstalled = true
    }
}

extension FriendFindViewController: ClientDelegate{
    func receivedMessage(message: Message) {
        if(message.senderUsername == "#5"){
            if (message.message != "#x"){
                FoundFriend(message: message)
            }
        }
        if (message.senderUsername == "#1"){
            let splitMessge = message.message.components(separatedBy: "/")
            let roomName = splitMessge[0]
            let senderName = splitMessge[1]
            let message = splitMessge[2]
            
            print(roomName + senderName + message)
        }
    }
}
