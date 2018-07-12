//
//  ProfileViewController.swift
//  GameStart
//
//  Created by 김민국 on 2018. 7. 4..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet var BackProfileView: UIImageView!
    @IBOutlet var ProfileView: UIImageView!
    @IBOutlet var ProfileName: UILabel!
    @IBOutlet var chatBtnView: UIButton!
    @IBOutlet var callBtnView: UIButton!
    @IBOutlet var xBtnView: UIButton!
    
    var client: Client!
    
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {

        
        BackProfileView.image = UIImage(named: "backProfile.jpg")
        ProfileView.image = UIImage(named: "profile.png")
        ProfileView.frame = CGRect(x: 142, y: 559, width: 90, height: 90)
        ProfileView.layer.cornerRadius = ProfileView.frame.width/2
        ProfileView.clipsToBounds = true

        chatBtnView.setBackgroundImage(UIImage(named: "chat.png"), for: .normal)
        chatBtnView.frame = CGRect(x: 122, y: 722, width: 48, height: 48)
        chatBtnView.layer.cornerRadius = chatBtnView.frame.width/2
        chatBtnView.clipsToBounds = true
        chatBtnView.backgroundColor = UIColor.clear
        
        callBtnView.setBackgroundImage(UIImage(named: "call.png"), for: .normal)
        callBtnView.frame = CGRect(x: 203, y: 722, width: 48, height: 48)
        callBtnView.layer.cornerRadius = callBtnView.frame.width/2
        callBtnView.clipsToBounds = true
        callBtnView.backgroundColor = UIColor.clear
        
        xBtnView.setBackgroundImage(UIImage(named: "xBtn.png"), for: .normal)
        xBtnView.backgroundColor = UIColor.clear
        
        xBtnView.frame = CGRect(x: 16, y: 44, width: 35, height: 35)
        
        ProfileName.center.x = self.view.center.x
        ProfileName.text = name
        ProfileName.sizeToFit()
    }
    
    @IBAction func xBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CallBtn(_ sender: Any) {
        
        let tab = UIApplication.shared.delegate?.window??.rootViewController as! UITabBarController
        /*
        self.dismiss(animated: false, completion:{
            tab.selectedIndex = 1
            
            let viewNC = tab.viewControllers![1] as! UINavigationController
            let RoomVC = viewNC.viewControllers[0] as! RoomListViewController
            RoomVC.performSegue(withIdentifier: "toChat", sender: self)
        })
 */
        self.view.window?.rootViewController?.dismiss(animated: false, completion: {
            tab.selectedIndex = 1
            
            let viewNC = tab.viewControllers![1] as! UINavigationController
            let RoomVC = viewNC.viewControllers[0] as! RoomListViewController

            RoomVC.client = self.client
            if RoomVC.Rooms.contains(where: {$0.key == self.ProfileName.text}){
                RoomVC.selectedRoomUser = self.ProfileName.text
                print("have room")
            }else{
                print("no room make it")
                let room = Room(roomname: self.ProfileName.text!, username: [self.client.username,self.ProfileName.text!], log: [], To: self.ProfileName.text!, have: false)
                RoomVC.Rooms.updateValue(room, forKey: self.ProfileName.text!)
                RoomVC.selectedRoomUser = self.ProfileName.text
                
            }
            RoomVC.performSegue(withIdentifier: "toChat", sender: self)
        })
    }

}
