//
//  NormalScene.swift
//  GameStart
//
//  Created by 김민국 on 2018. 7. 12..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class NormalScene: SKScene {
    let background = SKSpriteNode(imageNamed: "BG.png")
    var textV: SKSpriteNode!
    var myCharacter: SKSpriteNode!
    
    var characters = ["Tiger","Bear","Hedge","Wolf"]
    var MyAtlas = SKTextureAtlas()
    var MyArray = [SKTexture]()
    var myName: String!
    
    var TextView: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setBackGround()
        selectMyCharacter(index: Int.random(in: 0...3))
        textV = childNode(withName: "textView") as? SKSpriteNode
        textV.isHidden = true
    }
    func setBackGround(){
        background.zPosition = -1
        background.position = CGPoint.zero
        background.size = CGSize(width: frame.width, height: frame.height)
        addChild(background)
    }
    
    public func selectMyCharacter(index: Int){
        
        if index == 3{
            MyCharacterInit(CharacterName: characters[3])
        }else if index == 2{
            MyCharacterInit(CharacterName: characters[2])
        }else if index == 1{
            MyCharacterInit(CharacterName: characters[1])
        }else if index == 0{
            MyCharacterInit(CharacterName: characters[0])
        }
    }
    public func MyCharacterInit(CharacterName: String){
        
        myName = CharacterName
        myCharacter = SKSpriteNode(imageNamed: "\(CharacterName)Idle1.png")
        myCharacter.size = CGSize(width: 120, height: 120)
        myCharacter.position = CGPoint(x: -94, y: -178)
        myCharacter.zPosition = 1
        self.scene?.addChild(myCharacter)
        MyCharacterIdle()
    }
    
    public func MyCharacterSend(){
        MyArray.removeAll()
        MyAtlas = SKTextureAtlas(named: "\(myName!)Attack")
        
        for i in 1...MyAtlas.textureNames.count{
            let FName = "\(myName!)Attack\(i).png"
            MyArray.append(SKTexture(imageNamed: FName))
        }
  
        myCharacter.run(SKAction.animate(with: MyArray, timePerFrame: 0.3), withKey: "Attack")
        messageMove()
        
    }
    public func MyCharacterIdle(){
        MyArray.removeAll()
        MyAtlas = SKTextureAtlas(named: "\(myName!)Idle")
        
        for i in 1...MyAtlas.textureNames.count{
            let FName = "\(myName!)Idle\(i).png"
            MyArray.append(SKTexture(imageNamed: FName))
        }
        
        myCharacter.run(SKAction.repeatForever(SKAction.animate(with: MyArray, timePerFrame: 0.1)))
    }
    
    public func messageMove(){
        let item = self.spawnItem()
        self.scene?.addChild(item)
        
        let Move = SKAction.moveTo(x: 94, duration: 5)
        item.run(Move){
            item.removeFromParent()
        }
    }
    func spawnItem() -> SKSpriteNode{
        let item: SKSpriteNode?
        item = SKSpriteNode(imageNamed: "MSG.png")
        item?.size = CGSize(width: 31, height: 20)
        item?.position.x = myCharacter.position.x + 10
        item?.position.y = myCharacter.position.y
        
        return item!
    }
    
    public func addText(text: String){
        textV.isHidden = false
        TextView = childNode(withName: "textView/text") as? SKLabelNode
        TextView.position = CGPoint(x: -119.03, y: 23.484)
        TextView.fontSize = 14
        TextView.text = text
        TextView.lineBreakMode = .byWordWrapping
        TextView.numberOfLines = 2
        TextView.preferredMaxLayoutWidth = 240
        TextView.verticalAlignmentMode = .center
        TextView.horizontalAlignmentMode = .left
    }
}
