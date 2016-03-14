//
//  gameScene.swift
//  codenames
//
//  Created by Fritz Huie on 2/19/16.
//  Copyright © 2016 Fritz. All rights reserved.
//

import SpriteKit

enum tiletype {
    case red, blue, neutral, poison, redselected, blueselected, neutralselected, poisonselected
}

class Button : SKShapeNode{
    
    var wordValue:String = "nil"
    var number:Int = 0
    var color:SKColor = SKColor.blackColor()
    var colortype:tiletype = .neutral
    var team:tiletype = .neutral
    var selected: Bool = false
    
    func updateColor(){
        
    }
    
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
    var revealpressed:Bool = false
    var topBar = SKShapeNode()
    var currentTurn:tiletype = .red
    var fade = SKShapeNode()
    var currentwords = [String](count: 0, repeatedValue: "")
    
    var redWordsRemaining:Int = 0
    var blueWordsRemaining:Int = 0
    
    var gameIsOver:Bool = false
    
    var lockViewButton:Bool = false
    
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
        topBar = SKShapeNode(rect: CGRectMake(0, self.frame.height - topBarHeight,self.frame.width, topBarHeight))
        topBar.fillColor = purplecolor
        topBar.zPosition = 0
        topBar.fillColor = currentTurn == .red ? redTeamColor : blueTeamColor
        root.addChild(topBar)
        
        fade = SKShapeNode(rect: self.frame)
        fade.fillColor = SKColor.whiteColor()
        fade.zPosition = 100
        fade.alpha = 0.0
        addChild(fade)
        
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
        newGameLabel.fontSize = 20
        newGameLabel.zPosition = 2
        newGameLabel.position = CGPointMake(frame.width/10, self.frame.maxY - topBarHeight*0.5)
        newGameLabel.color = SKColor.blackColor()
        root.addChild(newGameLabel)
        
        let newGameButton = SKShapeNode(rect: CGRectMake(0, frame.maxY - topBarHeight, board.frame.width/5, topBarHeight))
        newGameButton.zPosition = 1
        newGameButton.fillColor = SKColor.blackColor()
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
                button.team = boardValue[buttonNumber]
                button.zPosition = 1
                button.name = "word tile"
                board.addChild(button)
                
                let word = SKLabelNode(text: currentwords[buttonNumber])
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
        updateTileColors()
    }
    
    func updateTileColors() {
        
        for t in board.children {
            let tile = t as! Button
            tile.fillColor = updateColorFor(tile)
        }
    }
    
    func updateColorFor(tile: Button) -> SKColor {
        if(teamView || tile.selected) {
            switch tile.colortype {
            case .red:
                return redcolor
            case .blue:
                return bluecolor
            case .poison:
                return poisoncolor
            case .redselected:
                return SKColor.redColor()
            case .blueselected:
                return SKColor.blueColor()
            case .poisonselected:
                return SKColor.blackColor()
            case .neutralselected:
                return SKColor.darkGrayColor()
            default:
                return neutralcolor
            }
        }else{
            return neutralcolor
        }
    }
    
    func newGame() {
        
        if (remainingWordList.count < 25){
            remainingWordList = wordlist
        }
        
        gameIsOver = false
        
        currentwords.removeAll()
        
        for _ in 1...25 {
            let i = Int(arc4random_uniform(UInt32(remainingWordList.count)))
            currentwords.append(remainingWordList[i])
            remainingWordList.removeAtIndex(i)
        }
        
        currentTurn = random() % 2 < 0 ? .red : .blue
        
        if(currentTurn == .red) {
            redWordsRemaining = 9
            blueWordsRemaining = 8
        }else{
            redWordsRemaining = 8
            blueWordsRemaining = 9
        }
        
        var blueRemaining:Int = blueWordsRemaining
        var redRemaining:Int = redWordsRemaining
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
    
    func tileSelect (tile: Button) {
        if(teamView || tile.selected){
            return
        }
        
        tile.selected = true
        switch tile.colortype {
        case .red:
            tile.colortype = .redselected
        case .blue:
            tile.colortype = .blueselected
        case .poison:
            tile.colortype = .poisonselected
        case .neutral:
            tile.colortype = .neutralselected
        default:
            print("color type invalid")
        }
        updateTileColors()
        
        if (tile.colortype == .poison) {
            print("poison pressed")
            gameOver(currentTurn == .red ? .blue : .red)
            return
        }

        
        if (tile.team == currentTurn && currentTurn == .red) {
            print("red point")
            redWordsRemaining--
            if(redWordsRemaining == 0){gameOver(.red)}
        }
        
        if(tile.team == currentTurn && currentTurn == .blue){
            print("blue point")
            blueWordsRemaining--
            if(blueWordsRemaining == 0){gameOver(.blue)}
        }
        
        endTurn()
    }
    
    func gameOver(winner: tiletype) {
        gameIsOver = true
        print("game over! Winner: \(winner == .red ? "red!" : "blue!")")
    }
    
    func endTurn() {
        currentTurn = currentTurn == .red ? .blue : .red
        topBar.fillColor = currentTurn == .red ? redTeamColor : blueTeamColor

        //TODO: animate new turn
        //TODO: pause touches during animation
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        revealpressed = false
        teamToggle.removeAllActions()
        teamToggle.alpha = 1.0
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
                    if(gameIsOver == true){
                        return
                    }
                    if(teamView){
                        disableTeamView()
                    }else if (lockViewButton == false){
                        lockViewButton = true
                        revealpressed = true
                        let timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "enableTeamView", userInfo: nil, repeats: false)
                        teamToggle.runAction(SKAction.sequence([SKAction.fadeAlphaTo(0.0, duration: 2.0), SKAction.fadeAlphaTo(1.0, duration: 0.2)]))
                    }
                    return
                case "new game":
                    newGame()
                case "word tile":
                    if(gameIsOver == true){
                        return
                    }
                    tileSelect(node as! Button)
            default:
                continue
            }
        }
    }
    
    func enableTeamView() {
        if(revealpressed){
            teamView = true
            teamToggle.texture = SKTexture(imageNamed: "eyeopen.png")
            updateTileColors()
        }
        revealpressed = false
        lockViewButton = false
    }
    
    func disableTeamView() {
        teamView = false
        teamToggle.texture = SKTexture(imageNamed: "eyeclosed.png")
        updateTileColors()
    }
    
    private let blueTeamColor = SKColor(colorLiteralRed: 0.1, green: 0.1, blue: 0.6, alpha: 1.0)
    private let redTeamColor = SKColor(colorLiteralRed: 0.6, green: 0.1, blue: 0.1, alpha: 1.0)
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
    
    private var remainingWordList = [String](count: 1, repeatedValue: "")
    
    private let wordlist = ["Acne", "Acre", "Addendum", "Advertise", "Aircraft", "Aisle", "Alligator", "Alphabetize", "America", "Ankle", "Apathy", "Applause", "Applesauc", "Application", "Archaeologist", "Aristocrat", "Arm", "Armada", "Asleep", "Astronaut", "Athlete", "Atlantis", "Aunt", "Avocado", "Baby-Sitter", "Backbone", "Bag", "Baguette", "Bald", "Balloon", "Banana", "Banister", "Baseball", "Baseboards", "Basketball", "Bat", "Battery", "Beach", "Beanstalk", "Bedbug", "Beer", "Beethoven", "Belt", "Bib", "Bicycle", "Big", "Bike", "Billboard", "Bird", "Birthday", "Bite", "Blacksmith", "Blanket", "Bleach", "Blimp", "Blossom", "Blueprint", "Blunt", "Blur", "Boa", "Boat", "Bob", "Bobsled", "Body", "Bomb", "Bonnet", "Book", "Booth", "Bowtie", "Box", "Boy", "Brainstorm", "Brand", "Brave", "Bride", "Bridge", "Broccoli", "Broken", "Broom", "Bruise", "Brunette", "Bubble", "Buddy", "Buffalo", "Bulb", "Bunny", "Bus", "Buy", "Cabin", "Cafeteria", "Cake", "Calculator", "Campsite", "Can", "Canada", "Candle", "Candy", "Cape", "Capitalism", "Car", "Cardboard", "Cartography", "Cat", "Cd", "Ceiling", "Cell", "Century", "Chair", "Chalk", "Champion", "Charger", "Cheerleader", "Chef", "Chess", "Chew", "Chicken", "Chime", "China", "Chocolate", "Church", "Circus", "Clay", "Cliff", "Cloak", "Clockwork", "Clown", "Clue", "Coach", "Coal", "Coaster", "Cog", "Cold", "College", "Comfort", "Computer", "Cone", "Constrictor", "Continuum", "Conversation", "Cook", "Coop", "Cord", "Corduroy", "Cot", "Cough", "Cow", "Cowboy", "Crayon", "Cream", "Crisp", "Criticize", "Crow", "Cruise", "Crumb", "Crust", "Cuff", "Curtain", "Cuticle", "Czar", "Dad", "Dart", "Dawn", "Day", "Deep", "Defect", "Dent", "Dentist", "Desk", "Dictionary", "Dimple", "Dirty", "Dismantle", "Ditch", "Diver", "Doctor", "Dog", "Doghouse", "Doll", "Dominoes", "Door", "Dot", "Drain", "Draw", "Dream", "Dress", "Drink", "Drip", "Drums", "Dryer", "Duck", "Dump", "Dunk", "Dust", "Ear", "Eat", "Ebony", "Elbow", "Electricity", "Elephant", "Elevator", "Elf", "Elm", "Engine", "England", "Ergonomic", "Escalator", "Eureka", "Europe", "Evolution", "Extension", "Eyebrow", "Fan", "Fancy", "Fast", "Feast", "Fence", "Feudalism", "Fiddle", "Figment", "Finger", "Fire", "First", "Fishing", "Fix", "Fizz", "Flagpole", "Flannel", "Flashlight", "Flock", "Flotsam", "Flower", "Flu", "Flush", "Flutter", "Fog", "Foil", "Football", "Forehead", "Forever", "Fortnight", "France", "Freckle", "Freight", "Fringe", "Frog", "Frown", "Gallop", "Game", "Garbage", "Garden", "Gasoline", "Gem", "Ginger", "Gingerbread", "Girl", "Glasses", "Goblin", "Gold", "Goodbye", "Grandpa", "Grape", "Grass", "Gratitude", "Gray", "Green", "Guitar", "Gum", "Gumball", "Hair", "Half", "Handle", "Handwriting", "Hang", "Happy", "Hat", "Hatch", "Headache", "Heart", "Hedge", "Helicopter", "Hem", "Hide", "Hill", "Hockey", "Homework", "Honk", "Hopscotch", "Horse", "Hose", "Hot", "House", "Houseboat", "Hug", "Humidifier", "Hungry", "Hurdle", "Hurt", "Hut", "Ice", "Implode", "Inn", "Inquisition", "Intern", "Internet", "Invitation", "Ironic", "Ivory", "Ivy", "Jade", "Japan", "Jeans", "Jelly", "Jet", "Jig", "Jog", "Journal", "Jump", "Key", "Killer", "Kilogram", "King", "Kitchen", "Kite", "Knee", "Kneel", "Knife", "Knight", "Koala", "Lace", "Ladder", "Ladybug", "Lag", "Landfill", "Lap", "Laugh", "Laundry", "Law", "Lawn", "Lawnmower", "Leak", "Leg", "Letter", "Level", "Lifestyle", "Ligament", "Light", "Lightsaber", "Lime", "Lion", "Lizard", "Log", "Loiterer", "Lollipop", "Loveseat", "Loyalty", "Lunch", "Lunchbox", "Lyrics", "Machine", "Macho", "Mailbox", "Mammoth", "Mark", "Mars", "Mascot", "Mast", "Matchstick", "Mate", "Mattress", "Mess", "Mexico", "Midsummer", "Mine", "Mistake", "Modern", "Mold", "Mom", "Monday", "Money", "Monitor", "Monster", "Mooch", "Moon", "Mop", "Moth", "Motorcycle", "Mountain", "Mouse", "Mower", "Mud", "Music", "Mute", "Nature", "Negotiate", "Neighbor", "Nest", "Neutron", "Niece", "Night", "Nightmare", "Nose", "Oar", "Observatory", "Office", "Oil", "Old", "Olympian", "Opaque", "Opener", "Orbit", "Organ", "Organize", "Outer", "Outside", "Ovation", "Overture", "Pail", "Paint", "Pajamas", "Palace", "Pants", "Paper", "Paper", "Park", "Parody", "Party", "Password", "Pastry", "Pawn", "Pear", "Pen", "Pencil", "Pendulum", "Penis", "Penny", "Pepper", "Personal", "Philosopher", "Phone", "Photograph", "Piano", "Picnic", "Pigpen", "Pillow", "Pilot", "Pinch", "Ping", "Pinwheel", "Pirate", "Plaid", "Plan", "Plank", "Plate", "Platypus", "Playground", "Plow", "Plumber", "Pocket", "Poem", "Point", "Pole", "Pomp", "Pong", "Pool", "Popsicle", "Population", "Portfolio", "Positive", "Post", "Princess", "Procrastinate", "Protestant", "Psychologist", "Publisher", "Punk", "Puppet", "Puppy", "Push", "Puzzle", "Quarantine", "Queen", "Quicksand", "Quiet", "Race", "Radio", "Raft", "Rag", "Rainbow", "Rainwater", "Random", "Ray", "Recycle", "Red", "Regret", "Reimbursement", "Retaliate", "Rib", "Riddle", "Rim", "Rink", "Roller", "Room", "Rose", "Round", "Roundabout", "Rung", "Runt", "Rut", "Sad", "Safe", "Salmon", "Salt", "Sandbox", "Sandcastle", "Sandwich", "Sash", "Satellite", "Scar", "Scared", "School", "Scoundrel", "Scramble", "Scuff", "Seashell", "Season", "Sentence", "Sequins", "Set", "Shaft", "Shallow", "Shampoo", "Shark", "Sheep", "Sheets", "Sheriff", "Shipwreck", "Shirt", "Shoelace", "Short", "Shower", "Shrink", "Sick", "Siesta", "Silhouette", "Singer", "Sip", "Skate", "Skating", "Ski", "Slam", "Sleep", "Sling", "Slow", "Slump", "Smith", "Sneeze", "Snow", "Snuggle", "Song", "Space", "Spare", "Speakers", "Spider", "Spit", "Sponge", "Spool", "Spoon", "Spring", "Sprinkler", "Spy", "Square", "Squint", "Stairs", "Standing", "Star", "State", "Stick", "Stockholder", "Stoplight", "Stout", "Stove", "Stowaway", "Straw", "Stream", "Streamline", "Stripe", "Student", "Sun", "Sunburn", "Sushi", "Swamp", "Swarm", "Sweater", "Swimming", "Swing", "Tachometer", "Talk", "Taxi", "Teacher", "Teapot", "Teenager", "Telephone", "Ten", "Tennis", "Thief", "Think", "Throne", "Through", "Thunder", "Tide", "Tiger", "Time", "Tinting", "Tiptoe", "Tiptop", "Tired", "Tissue", "Toast", "Toilet", "Tool", "Toothbrush", "Tornado", "Tournament", "Tractor", "Train", "Trash", "Treasure", "Tree", "Triangle", "Trip", "Truck", "Tub", "Tuba", "Tutor", "Television", "Twang", "Twig", "Twitterpated", "Type", "Unemployed", "Upgrade", "Vest", "Vision", "Wag", "Water", "Watermelon", "Wax", "Wedding", "Weed", "Welder", "Whatever", "Wheelchair", "Whiplash", "Whisk", "Whistle", "White", "Wig", "Will", "Windmill", "Winter", "Wish", "Wolf", "Wool", "World", "Worm", "Wristwatch", "Yardstick", "Zamboni", "Zen", "Zero", "Zipper", "Zone", "Zoo"]

}