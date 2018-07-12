//
//  GameScene.swift
//  GameStart
//
//  Created by 김민국 on 2018. 7. 8..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene{
    
    var questionText: SKLabelNode?
    var redGageBar: SKSpriteNode!
    var blueGageBar: SKSpriteNode!
    
    var originX: CGFloat!
    var orginWidth: CGFloat!
    let textArray: [String] = ["Good morning. I'm in class and I have a cell phone. Send it home.",
                               "Today is a holiday and I'm in school.",
                               "I want to go on a trip.",
                               "We have Hogwarts in our school. Would you like go with me",
                               "If you have two lives, ride a bicycle and go to school."]
    
    let background = SKSpriteNode(imageNamed: "BG.png")
    
    var myCharacter: SKSpriteNode!
    var EnemyCharacter: SKSpriteNode!
    var myName: String!
    var EnemyName: String!
    
    var MyAtlas = SKTextureAtlas()
    var MyArray = [SKTexture]()
    var EnemyAtlas = SKTextureAtlas()
    var EnemyArray = [SKTexture]()
    
    var questionExits: Bool = false
    var currentQuestion = Int()
    var characters = ["Tiger","Bear","Hedge","Wolf"]
    
    var ImReady: Bool = false // when question made, make it false
    var EnemyReady: Bool = false
    
    var ImMoving: Bool = false
    var EnemyMoving: Bool = false
    
    var myHP: Int = 0
    var enemyHP: Int = 0
    var IAM: String = ""
    
    override func didMove(to view: SKView) {
        
        setBackGround()
        
    }

    override func update(_ currentTime: TimeInterval) {
        if (ImReady == true && EnemyReady == true){
            if (ImMoving == false){
                MyCharacterMove()
            }
            if (EnemyMoving == false){
                EnemyCharacterMove()
            }
        }
    }

    func setBackGround(){
        background.zPosition = -1
        background.position = CGPoint.zero
        background.size = CGSize(width: frame.width, height: frame.height)
        addChild(background)
        
        let myHouse = childNode(withName: "myHouse") as! SKSpriteNode
        myHouse.texture = SKTexture(imageNamed: "House1.png")

        let enemyHouse = childNode(withName: "enemyHouse") as! SKSpriteNode
        enemyHouse.texture = SKTexture(imageNamed: "House2.png")
        
        redGageBar = childNode(withName: "redGageBar") as? SKSpriteNode
        blueGageBar = childNode(withName: "blueGageBar") as? SKSpriteNode
    }
    
    public func questionCreate(index: Int){
        if (questionExits == true){
            questionText?.removeFromParent()
            questionExits = false
        }
        currentQuestion = index
        questionText = childNode(withName: "questionText") as? SKLabelNode
        questionText?.lineBreakMode = .byWordWrapping
        questionText?.numberOfLines = 2
        questionText?.text = textArray[index]
        questionText?.preferredMaxLayoutWidth = 300
        questionExits = true
    }
    func redHPDecrease(){
        let redHpWidth = redGageBar.frame.width
        let originX = redGageBar?.position.x
        redGageBar.size.width = redHpWidth - 16.0
        redGageBar.position.x = originX! + 8
    }
    func blueHPDecrease(){
        let blueHpWidth = blueGageBar.frame.width
        let originX = blueGageBar.position.x
        blueGageBar.size.width = blueHpWidth - 16.0
        blueGageBar.position.x = originX - 8
    }
    
    public func selectMyCharacter(text: String){
        let correctCount = Float(textArray[currentQuestion].count)
        
        if text.count < Int(correctCount * 0.25){
            MyCharacterInit(CharacterName: characters[3])
            myHP = 0
        }else if text.count < Int(correctCount * 0.50){
            MyCharacterInit(CharacterName: characters[2])
            myHP = 1
        }else if text.count < Int(correctCount * 0.75){
            MyCharacterInit(CharacterName: characters[1])
            myHP = 2
        }else if text.count <= Int(correctCount){
            MyCharacterInit(CharacterName: characters[0])
            myHP = 3
        }
    }
    public func selectEnemyCharacter(text: String){
        let correctCount = Float(textArray[currentQuestion].count)
        
        if text.count < Int(correctCount * 0.25){
            EnemyCharacterInit(CharacterName: characters[3])
            enemyHP = 0
        }else if text.count < Int(correctCount * 0.50){
            EnemyCharacterInit(CharacterName: characters[2])
            enemyHP = 1
        }else if text.count < Int(correctCount * 0.75){
            EnemyCharacterInit(CharacterName: characters[1])
            enemyHP = 2
        }else if text.count <= Int(correctCount){
            EnemyCharacterInit(CharacterName: characters[0])
            enemyHP = 3
        }
    }
    
    public func MyCharacterInit(CharacterName: String){

        myName = CharacterName
        myCharacter = SKSpriteNode(imageNamed: "\(CharacterName)Idle1.png")
        myCharacter.size = CGSize(width: 120, height: 120)
        myCharacter.position = CGPoint(x: -94, y: -178)
        myCharacter.zPosition = 1
        self.scene?.addChild(myCharacter)
        MyCharacterAnim(Name: myName, stateName: "Idle", isRepeat: true, isDead: false)
        ImReady = true
        ImMoving = false
    }
    public func MyCharacterAnim(Name: String, stateName: String, isRepeat: Bool, isDead: Bool){
        myCharacter.removeAction(forKey: "Idle")
        myCharacter.removeAction(forKey: "Run")
        myCharacter.removeAction(forKey: "Attack")
        myCharacter.removeAction(forKey: "Dead")
        MyArray.removeAll()
        if (isDead == false){
            MyAtlas = SKTextureAtlas(named: "\(Name)\(stateName)")
            
            for i in 1...MyAtlas.textureNames.count{
                let FName = "\(Name)\(stateName)\(i).png"
                MyArray.append(SKTexture(imageNamed: FName))
            }
        }else{
            MyAtlas = SKTextureAtlas(named: "\(stateName)")
            
            for i in 1...MyAtlas.textureNames.count{
                let FName = "\(stateName)\(i).png"
                MyArray.append(SKTexture(imageNamed: FName))
            }
        }
        
        if isRepeat == true{
            myCharacter.run(SKAction.repeatForever(SKAction.animate(with: MyArray, timePerFrame: 0.1)), withKey: "\(stateName)")
        }else{
            myCharacter.run(SKAction.animate(with: MyArray, timePerFrame: 0.1), withKey: "\(stateName)")
        }
        
    }
    public func MyCharacterMove(){
        MyCharacterAnim(Name: myName, stateName: "Run", isRepeat: true, isDead: false)
        
        ImMoving = true
        let Move = SKAction.moveTo(x: -20, duration: 3)
        myCharacter.run(Move){
            self.MyCharacterAnim(Name: self.myName, stateName: "Attack", isRepeat: false, isDead: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if (self.myHP < self.enemyHP){
                    self.MyCharacterAnim(Name: self.myName, stateName: "Dead", isRepeat: false, isDead: true)
                    self.blueHPDecrease()
                
                }else{
                    self.MyCharacterAnim(Name: self.myName,     stateName: "Idle", isRepeat: true, isDead:  false)
                }
            })
        }
    }
    
    public func EnemyCharacterInit(CharacterName: String){
        EnemyName = CharacterName
        EnemyCharacter = SKSpriteNode(imageNamed: "\(CharacterName)Idle1.png")
        EnemyCharacter.size = CGSize(width: 120, height: 120)
        EnemyCharacter.position = CGPoint(x: 94, y: -178)
        EnemyCharacter.zPosition = 1
        EnemyCharacter.xScale = -1
        self.scene?.addChild(EnemyCharacter)
        EnemyCharacterAnim(Name: EnemyName, stateName: "Idle", isRepeat: true, isDead: false)
        EnemyReady = true
        EnemyMoving = false
    }
    
    public func EnemyCharacterAnim(Name: String, stateName: String, isRepeat: Bool, isDead: Bool){
        EnemyCharacter.removeAction(forKey: "Idle")
        EnemyCharacter.removeAction(forKey: "Run")
        EnemyCharacter.removeAction(forKey: "Attack")
        EnemyCharacter.removeAction(forKey: "Dead")
        EnemyArray.removeAll()
        if (isDead == false){
            EnemyAtlas = SKTextureAtlas(named: "\(Name)\(stateName)")
            
            for i in 1...EnemyAtlas.textureNames.count{
                let FName = "\(Name)\(stateName)\(i).png"
                EnemyArray.append(SKTexture(imageNamed: FName))
            }
        }else{
            EnemyAtlas = SKTextureAtlas(named: "\(stateName)")
            
            for i in 1...EnemyAtlas.textureNames.count{
                let FName = "\(stateName)\(i).png"
                EnemyArray.append(SKTexture(imageNamed: FName))
            }
        }
        
        if isRepeat == true{
            EnemyCharacter.run(SKAction.repeatForever(SKAction.animate(with: EnemyArray, timePerFrame: 0.1)), withKey: "\(stateName)")
        }else{
            EnemyCharacter.run(SKAction.animate(with: EnemyArray, timePerFrame: 0.1), withKey: "\(stateName)")
        }
    }
    
    public func EnemyCharacterMove(){
        EnemyCharacterAnim(Name: EnemyName, stateName: "Run", isRepeat: true, isDead: false)
        EnemyMoving = true
        let Move = SKAction.moveTo(x: 20, duration: 3)
        EnemyCharacter.run(Move){
            self.EnemyCharacterAnim(Name: self.EnemyName, stateName: "Attack", isRepeat: false, isDead: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if (self.enemyHP < self.myHP){
                    self.EnemyCharacterAnim(Name: self.EnemyName, stateName: "Dead", isRepeat: false, isDead: true)
                    self.redHPDecrease()
                }else{
                    self.EnemyCharacterAnim(Name: self.EnemyName, stateName: "Idle", isRepeat: true, isDead: false)
                }
            })
        }
    }
}

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
