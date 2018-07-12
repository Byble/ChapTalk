//
//  LogInViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 6. 26..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit


class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var LoginTextView: UITextField!
    @IBOutlet var PasswdTextView: UITextField!
    @IBOutlet var ApplyBtnView: UIButton!
    
    let client = Client()
    
    let viewColor: UIColor = UIColor(red: 109/255, green: 201/255, blue: 149/255, alpha: 1)
    let LoginBtnColor: UIColor = UIColor(red: 89/255, green: 156/255, blue: 120/255, alpha: 1)
    
    var LoginImage: UIImage?
    var PasswdImage: UIImage?
    var LoginImageView: UIImageView!
    var PasswdImageView: UIImageView!
    
    var helloView = UIView()
    var loadingView = UIView()
    var loading: UIActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        

        self.LoginImage = UIImage(named: "login.png")
        self.PasswdImage = UIImage(named: "lock.png")
        
        self.LoginImageView = UIImageView(image: self.LoginImage)
        self.LoginImageView.tintColor = UIColor.white
        self.PasswdImageView = UIImageView(image: self.PasswdImage)
        self.PasswdImageView.tintColor = UIColor.white
        
        self.LoginImageView.frame.size = CGSize(width: LoginTextView.frame.size.height - 10, height: LoginTextView.frame.size.height - 10)
        self.PasswdImageView.frame.size = CGSize(width: PasswdTextView.frame.size.height - 10, height: PasswdTextView.frame.size.height - 10)
        
        
        let LoginTextPlaceholder = NSAttributedString(string: "아이디", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        LoginTextView.attributedPlaceholder = LoginTextPlaceholder
        LoginTextView.textColor = UIColor.white
        LoginTextView.font = UIFont.systemFont(ofSize: 15)
        LoginTextView.contentVerticalAlignment = .center
        LoginTextView.setupBottomBorder(backgroundColor: viewColor, BborderColor: UIColor.white)
        LoginTextView.keyboardType = .asciiCapable
        
        let LoginImageV = UIView(frame: CGRect(x: 0, y: 0, width: LoginTextView.frame.size.height + 5, height: LoginTextView.frame.size.height - 5))
        LoginImageV.addSubview(LoginImageView)
        LoginTextView.leftView = LoginImageV
        LoginTextView.leftViewMode = .always
        LoginTextView.spellCheckingType = .no
        LoginTextView.autocorrectionType = .no
        //LoginTextView.paddingLeftCustom(width: 30)
        
        let PasswdPlaceholder = NSAttributedString(string: "비밀번호", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        PasswdTextView.attributedPlaceholder = PasswdPlaceholder
        PasswdTextView.textColor = UIColor.white
        PasswdTextView.font = UIFont.systemFont(ofSize: 15)
        PasswdTextView.contentVerticalAlignment = .center
        PasswdTextView.setupBottomBorder(backgroundColor: viewColor, BborderColor: UIColor.white)
        PasswdTextView.keyboardType = .asciiCapable
        
        let PassImageV = UIView(frame: CGRect(x: 0, y: 0, width: PasswdTextView.frame.size.height + 5, height: PasswdTextView.frame.size.height - 5))
        PassImageV.addSubview(PasswdImageView)
        PasswdTextView.leftView = PassImageV
        PasswdTextView.leftViewMode = .always
        PasswdTextView.spellCheckingType = .no
        PasswdTextView.autocorrectionType = .no
        //PasswdTextView.paddingLeftCustom(width: 30)
        
        ApplyBtnView.setTitle("로그인", for: .normal)
        ApplyBtnView.setTitleColor(UIColor.white, for: .normal)
        ApplyBtnView.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        ApplyBtnView.backgroundColor = LoginBtnColor
        
        self.view.backgroundColor = viewColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoginTextView.delegate = self
        PasswdTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        client.delegate = self
    }
    
    @objc func keyboardWillShow(_ sender: Notification){
        self.view.frame.origin.y = -100
    }

    @objc func keyboardWillHide(_ sender: Notification){
        self.view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func LoginBtn(_ sender: UIButton) {
        if (LoginTextView.text != "" && PasswdTextView.text != "")
        {
            setupLoading()
            self.view.endEditing(true)
            
            client.setupNetwork()
        }
    }
    @objc func HelloOkBtn(){
        self.performSegue(withIdentifier: "ToRoom", sender: self)
    }
    func setupLoading(){
        
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        self.loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        loading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loading?.center = self.loadingView.center
        loading?.hidesWhenStopped = false
        loading?.startAnimating()
        self.loadingView.addSubview(loading!)
        self.view.addSubview(loadingView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToRoom"){
            let tabVC = segue.destination as? UITabBarController
            
            let navVC1 = tabVC?.viewControllers![0] as? UINavigationController
            let navVC2 = tabVC?.viewControllers![1] as? UINavigationController
            
            let Friend = navVC1?.topViewController as! FriendListTableViewController
            let Room = navVC2?.topViewController as! RoomListViewController
            
            Friend.client = client
            Room.client = client
        }
    }
}

extension LogInViewController: ClientDelegate{
    func receivedMessage(message: Message) {
        if(message.senderUsername == "#4"){
            
            loading?.stopAnimating()
            self.loadingView.removeFromSuperview()
            
//            self.helloView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
//            self.helloView.backgroundColor = UIColor.red
//
//            let okBtn = UIButton(frame: CGRect(x: 0, y: self.helloView.center.y * 1.5, width: 150, height: 30))
//            okBtn.center.x = helloView.frame.width / 2
//            okBtn.addTarget(self, action: #selector(HelloOkBtn), for: .touchUpInside)
//            okBtn.backgroundColor = UIColor.yellow
//            okBtn.setTitle("확인", for: .normal)
//            self.helloView.addSubview(okBtn)
//
//            self.view.addSubview(self.helloView)
            
            let alert = UIAlertController(title: nil, message: "로그인 하였습니다.", preferredStyle: .alert)
            
            let okbtn = UIAlertAction(title: "ok", style: .default) { (action) -> Void in
                self.HelloOkBtn()
            }
            alert.addAction(okbtn)
            
            self.present(alert, animated: false)
            client.username = LoginTextView.text!
        }
    }
    
    
}

@IBDesignable extension UITextField{
    
    func paddingLeftCustom(width: CGFloat){
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    func paddingRightCustom(width: CGFloat){
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.size.height))
        rightView = paddingView
        rightViewMode = .always
    }

    func setupBottomBorder(backgroundColor: UIColor, BborderColor: UIColor){
        self.layer.backgroundColor = backgroundColor.cgColor
        
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = BborderColor.cgColor
    }
}

@IBDesignable extension UIButton{
    @IBInspectable var borderWidth: CGFloat {
        get{
            return self.layer.borderWidth
        }
        set{
            let customWidth = newValue
            self.layer.borderWidth = customWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get{
            return self.borderColor
        }
        set{
            let customColor = newValue
            self.layer.borderColor = customColor.cgColor
        }
    }
}

