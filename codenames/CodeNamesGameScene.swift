//
//  gameScene.swift
//  codenames
//
//  Created by Fritz Huie on 2/19/16.
//  Copyright © 2016 Fritz. All rights reserved.
//

import SpriteKit

class Button : SKShapeNode{
    var wordValue:String = "nil"
    var number:Int = 0
    var color:SKColor = SKColor.blackColor()
    
    func assign(word: String, num: Int) {
        wordValue = word
        number = num
        print(wordValue)
        print(number)
    }
    
}

class CodeNamesGameScene: SKScene {
    
    private let root = SKNode()
    private var topBarHeight = CGFloat()
    private var boardHeight = CGFloat()
    let buttons = [Button](count: 25, repeatedValue: Button())
    
    override func didMoveToView(view: SKView) {
        topBarHeight = self.frame.height / CGFloat(5.0)
        boardHeight = self.frame.height - topBarHeight
        
        backgroundColor = SKColor.whiteColor()
        constructScene()
    }
    
    private func constructScene() {

        root.name = nil
        addChild(root)
        
        //add top bar
        let topBar = SKShapeNode(rect: CGRectMake(0,self.frame.height - topBarHeight,self.frame.width, topBarHeight))
        topBar.fillColor = purplecolor
        topBar.zPosition = 0
        root.addChild(topBar)
        
        //add toggle button
        let teamToggle = SKShapeNode(rect: CGRectMake(self.frame.width * 0.81,self.frame.height - (topBarHeight * 0.8),self.frame.width * 0.16, topBarHeight * 0.6))
        teamToggle.fillColor = redcolor
        teamToggle.zPosition = 1
        root.addChild(teamToggle)
        
        //add the board space
        let board = SKShapeNode(rect: CGRectMake(0,0,self.frame.width, self.frame.height - CGFloat(topBarHeight)))
        board.fillColor = SKColor.blackColor()
        board.zPosition = 0
        root.addChild(board)
        
        //Build buttons in the board space
        let buttonSize = CGSizeMake(board.frame.width/5, boardHeight/5)
        var buttonNumber = 0
        for y in 0...4 {
            for x in 0...4 {
                
                let button = Button(rect: CGRectMake(0, 0, buttonSize.width, buttonSize.height))
                button.wordValue = words[buttonNumber]
                button.number = buttonNumber
                button.position = CGPointMake(buttonSize.width * CGFloat(x), buttonSize.height * CGFloat(y))
                button.name = words[buttonNumber]
                button.fillColor = neutralcolor
                button.zPosition = 1
                root.addChild(button)
                
                let word = SKLabelNode(text: words[buttonNumber])
                word.fontColor = SKColor.blackColor()
                word.fontSize = word.text!.characters.count > 10 ? 22 : 24
                word.fontName = "ArialHebrew-Bold"
                word.position = CGPointMake(button.position.x + buttonSize.width/2, button.position.y + buttonSize.height/3)
                word.name = nil
                word.zPosition = 2
                root.addChild(word)
                
                buttonNumber++
            }
        }
        //assign random correctness values
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(root)
        let touchedNodes = root.nodesAtPoint(touchLocation)
        
        for node in touchedNodes {
            if(node.name == nil) {
                continue
            }
            if(node.name != nil){
                print(node.name)
            }
        }
    }
    
    private let redcolor = SKColor(colorLiteralRed: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
    private let bluecolor = SKColor(colorLiteralRed: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
    private let purplecolor = SKColor(colorLiteralRed: 141.0/255.0, green: 113.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    private let neutralcolor = SKColor(colorLiteralRed: 193.0/255.0, green: 173.0/255.0, blue: 148.0/255.0, alpha: 1.0)
    private let blackcolor = SKColor(colorLiteralRed: 53, green: 41, blue: 41, alpha: 255)
    
    private let words = [   "one", "two", "three", "four", "five",
                    "six", "seven", "eight", "nine", "ten",
                    "eleven", "twelve", "thirteen", "fourteen", "fifteen",
                    "sixteen", "seventeen", "eighteen", "nineteen", "twenty",
                    "twentyone", "twentytwo", "twentytthree", "tentyfour", "twentyfive"]
}