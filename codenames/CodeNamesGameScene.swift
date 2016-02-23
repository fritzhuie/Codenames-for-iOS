//
//  gameScene.swift
//  codenames
//
//  Created by Fritz Huie on 2/19/16.
//  Copyright © 2016 Fritz. All rights reserved.
//

import SpriteKit

enum tiletype {
    case red, blue, neutral, poison
}

class Button : SKShapeNode{
    var wordValue:String = "nil"
    var number:Int = 0
    var color:SKColor = SKColor.blackColor()
    var colortype:tiletype = .neutral
    
    func setTeam(team: String) {
        
    }
    
}

class CodeNamesGameScene: SKScene {
    
    let root = SKNode()
    var topBarHeight = CGFloat()
    
    var board = SKShapeNode()
    var boardHeight = CGFloat()
    var boardValue = [tiletype](count: 25, repeatedValue: .neutral)
    
    let teamToggle = SKSpriteNode(imageNamed: "eyeclosed.png")
    var teamView:Bool = false
    
    override func didMoveToView(view: SKView) {
        topBarHeight = self.frame.height / CGFloat(5.0)
        boardHeight = self.frame.height - topBarHeight
        
        backgroundColor = SKColor.whiteColor()
        root.name = nil
        addChild(root)
        
        newGame()
    }
    
    private func constructScene() {
        root.removeAllChildren()
        //add top bar
        let topBar = SKShapeNode(rect: CGRectMake(0, self.frame.height - topBarHeight,self.frame.width, topBarHeight))
        topBar.fillColor = purplecolor
        topBar.zPosition = 0
        root.addChild(topBar)
        
        //add toggle button
        teamToggle.size = CGSizeMake(topBarHeight*2, topBarHeight * 1)
        teamToggle.position = CGPointMake(self.frame.maxX - teamToggle.size.width/2, self.frame.maxY - teamToggle.size.height/2)
        teamToggle.size = CGSizeMake(topBarHeight * 1.8, topBarHeight * 0.9) //shrink button
        teamToggle.color = SKColor.whiteColor()
        teamToggle.zPosition = 1
        teamToggle.name = "reveal"
        root.addChild(teamToggle)
        
        //add the board space
        board = SKShapeNode(rect: CGRectMake(0,0,self.frame.width, self.frame.height - CGFloat(topBarHeight)))
        board.fillColor = SKColor.blackColor()
        board.zPosition = 0
        root.addChild(board)
        
        let words = SKNode()
        root.addChild(words)
        
        let newGameLabel = SKLabelNode(text: "New Game")
        newGameLabel.zPosition = 2
        newGameLabel.position = CGPointMake(frame.width/5, self.frame.maxY - topBarHeight*0.7)
        newGameLabel.color = SKColor.blackColor()
        root.addChild(newGameLabel)
        
        let newGameButton = SKShapeNode(rect: CGRectMake(0, frame.maxY - topBarHeight, board.frame.width/5, topBarHeight))
        newGameButton.zPosition = 1
        newGameButton.fillColor = SKColor.whiteColor()
        newGameButton.name = "new game"
        root.addChild(newGameButton)
        
        
        //Build buttons in the board space
        let buttonSize = CGSizeMake(board.frame.width/5, boardHeight/5)
        var buttonNumber = 0
        for y in 0...4 {
            for x in 0...4 {
                
                let button = Button(rect: CGRectMake(0, 0, buttonSize.width, buttonSize.height))
                button.wordValue = samplewords[buttonNumber]
                button.number = buttonNumber
                button.position = CGPointMake(buttonSize.width * CGFloat(x), buttonSize.height * CGFloat(y))
                button.name = samplewords[buttonNumber]
                button.colortype = boardValue[buttonNumber]
                button.fillColor = teamView ? colorForTile(buttonNumber) : neutralcolor
                button.zPosition = 1
                board.addChild(button)
                
                let word = SKLabelNode(text: samplewords[buttonNumber])
                word.fontColor = SKColor.blackColor()
                word.fontSize = word.text!.characters.count > 10 ? 22 : 24
                word.fontName = "ArialHebrew-Bold"
                word.position = CGPointMake(button.position.x + buttonSize.width/2, button.position.y + buttonSize.height/3)
                word.name = nil
                word.zPosition = 2
                words.addChild(word)
                
                buttonNumber++
            }
        }
    }
    
    func enableTeamView() {
        teamView = true
        teamToggle.texture = SKTexture(imageNamed: "eyeopen.png")
        constructScene()
    }
    
    func disableTeamView() {
        teamView = false
        teamToggle.texture = SKTexture(imageNamed: "eyeclosed.png")
        constructScene()
    }
    
    func newGame() {
        
        //generate random board
        
        var redRemaining:Int = 8
        var blueRemaining:Int = 8
        var poisonRemaining:Int = 1
        
        for i in 0...24 {
            boardValue[i] = .neutral
        }
        
        while (redRemaining > 0 || blueRemaining > 0 || poisonRemaining > 0) {
            let i = Int(arc4random_uniform(UInt32(boardValue.count)))
            if (boardValue[i] == .neutral) {
                if redRemaining > 0 {
                    boardValue[i] = .red
                    redRemaining--
                }else if (blueRemaining > 0) {
                    boardValue[i] = .blue
                    blueRemaining--
                }else if (poisonRemaining > 0) {
                    boardValue[i] = .poison
                    poisonRemaining--
                }
            }
        }
        constructScene()
    }
    
    func colorForTile(tile: Int) -> SKColor {
        switch boardValue[tile] {
            case .red:
                return redcolor
            case .blue:
                return bluecolor
            case .poison:
                return poisoncolor
        default:
            return neutralcolor
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.locationInNode(root)
        let touchedNodes = root.nodesAtPoint(touchLocation)
        
        //print("Touch: \(touchLocation.x), \(touchLocation.y)")
        
        for node in touchedNodes {
            
            if(node.name == nil) {
                continue
            }
            print(node.name)
            
            switch node.name! as String {
                case "reveal":
                    teamView ? disableTeamView() : enableTeamView()
                    return
                case "new game":
                    newGame()
            default:
                continue
            }
        }
    }
    
    private let redcolor = SKColor(colorLiteralRed: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
    private let bluecolor = SKColor(colorLiteralRed: 0.2, green: 0.2, blue: 0.8, alpha: 1.0)
    private let purplecolor = SKColor(colorLiteralRed: 141.0/255.0, green: 113.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    private let neutralcolor = SKColor(colorLiteralRed: 193.0/255.0, green: 173.0/255.0, blue: 148.0/255.0, alpha: 1.0)
    private let poisoncolor = SKColor(colorLiteralRed: 0.2, green: 0.3, blue: 0.2, alpha: 1.0)
    
    private let samplewords = [   "one", "two", "three", "four", "five",
                    "six", "seven", "eight", "nine", "ten",
                    "eleven", "twelve", "thirteen", "fourteen", "fifteen",
                    "sixteen", "seventeen", "eighteen", "nineteen", "twenty",
                    "twentyone", "twentytwo", "twentytthree", "tentyfour", "twentyfive"]
}