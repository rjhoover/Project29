//
//  GameScene.swift
//  Project29
//
//  Created by Robert Hoover on 2023-05-19.
//

import SpriteKit

enum CollisionType: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()
    
    // we plan on making the the game scene tell the
    // view controller talk to each other and
    // making the view controller tell the game scene
    // talk to each other.
    // we don't want to create a strong reference cycle
    // so we should declare one of them as 'weak'.
    // the game controller already strongly owns the
    // game scene (it owns the SKView inside itself,
    // and the view owns the game scene).
    // so it's owned, but we don't have a reference to it.
    weak var viewController: GameViewController?
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    // variables to track the number of lives left during game play
    var player1NumLives: Int = 3
    var player2NumLives: Int = 3
    
    // arrays to store nodes for each of the player lives sprites
    var player1LivesNodes = [SKSpriteNode]()
    var player2LivesNodes = [SKSpriteNode]()

    // which player is the one launching the banana
    var currentPlayer = 1

    override func didMove(to view: SKView) {
        print("in didMove to")
        // give the scene a dark blue color to represent
        // the night sky.
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)

        // let us know when a collision occurs
        // (added SKPhysicsContactDelegate to class definition)
        physicsWorld.contactDelegate = self
        
        // to show the current contents of the two lives arrays
        print("  before createLives, player1LivesNodes.count = \(player1LivesNodes.count)")
        print("  before createLives, player2LivesNodes.count = \(player2LivesNodes.count)")
        
        createBuildings()
        createPlayers()
        createLives()
    }
    
    
    func createBuildings() {
        // draw the buildings moving horizontally across
        // the screen, filling the space with buildings
        // of various sizes until we hit the far edge of
        // the screen.
        // each building needs to be a random size.
        
        // for the height, it can be anything between
        // 300 and 600 pixels high.
        // for the width, it should divide evenly into
        // 40 so that our window drawing code is simple.
        // so, we'll generate a random number between
        // 2 and 4 then multiply that by 40 to give us
        // buildings that are 80, 120, or 160 points wide.
        
        // start a little off the edge of the screen so
        // it looks like the buildings keep going past
        // the screen's edge.
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let width = Int.random(in: 2...4) * 40
            let height = Int.random(in: 300...600)
            
            let size = CGSize(width: CGFloat(width), height: CGFloat(height))
            // add a two-point gap between buildings
            currentX += size.width + 2
            
            // all buildings start out as red and then a
            // random texture is applied over it.
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    func createLives() {
        print("in createLives")
        print("  starting out, player1LivesNodes.count = \(player1LivesNodes.count)")
        print("  starting out, player2LivesNodes.count = \(player2LivesNodes.count)")

        /// for some reason, these two arrays are empty
        /// even after they've been populated and nodes
        /// have been hidden.
        /// didMove(to:) gets called whenever the scene is initially presented
        /// or reloaded.
        
        if player1LivesNodes.isEmpty && player2LivesNodes.isEmpty {
            print("  arrays are both empty, creating lives nodes")
            // create initial lives nodes and add to lives arrays
            let livesSpriteWidth = Int(player1.size.width / 2)
            let livesSpriteSize = CGSize(width: livesSpriteWidth, height: livesSpriteWidth)
            
            /// all these label values are nil for some reason
//            let lives1XPosition = Int(viewController?.player1ScoreLabel.frame.maxX ?? 138)
//            let lives2XPosition = Int(viewController?.player2ScoreLabel.frame.minX ?? 800)
//            let livesYPosition = viewController?.player1ScoreLabel.frame.maxY ?? 693
            
            /// use hard-coded values for now
            let lives1XPosition = 138
            let lives2XPosition = 800
            let livesYPosition = 693

            for i in 0..<3 {
                // create a sprite for a tiny gorilla for player 1
                let spriteNode1 = SKSpriteNode(imageNamed: "player")
                spriteNode1.scale(to: livesSpriteSize)
                spriteNode1.position = CGPoint(x: lives1XPosition + (i * livesSpriteWidth), y: livesYPosition)
                spriteNode1.name = "player1Life\(i)"
//                print("\(spriteNode1.name) = \(spriteNode1.position))")
                spriteNode1.zPosition = 2
                addChild(spriteNode1)
                // add sprite to screen and to player1LivesNode
                player1LivesNodes.append(spriteNode1)
                
                // repeat for player 2
                let spriteNode2 = SKSpriteNode(imageNamed: "player")
                spriteNode2.scale(to: livesSpriteSize)
                spriteNode2.position = CGPoint(x: lives2XPosition + (i * livesSpriteWidth), y:  livesYPosition)
                spriteNode2.name = "player2Life\(i)"
//                print("\(spriteNode2.name) = \(spriteNode2.position))")
                spriteNode2.zPosition = 2
                addChild(spriteNode2)
                player2LivesNodes.append(spriteNode2)
            }
        } else {
            // one or both of the arrays is not empty
            print("  one or more arrays was not empty, not creating lives nodes")
        }
        print("  at end, player1LivesNodes.count = \(player1LivesNodes.count)")
        print("  at end, player2LivesNodes.count = \(player2LivesNodes.count)")
    }
    
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        // player image is basically round
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        // start player1 on top of second building
        let player1Building = buildings[1]
        
        // to put the player on top of a building, we need the
        // height of the building plus the player height
        // divided by 2 (to get the center)
        let player1YPosition = player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2)
        player1.position = CGPoint(x: player1Building.position.x, y: player1YPosition)
        addChild(player1)

        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        // player image is basically round
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        // start player2 on top of the second to last building
        let player2Building = buildings[buildings.count - 2]
        
        // to put the player on top of a building, we need the
        // height of the building plus the player height
        // divided by 2 (to get the center)
        let player2YPosition = player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2)
        player2.position = CGPoint(x: player2Building.position.x, y: player2YPosition)
        addChild(player2)
    }
    
    func launch(angle: Int, velocity: Int) {
        // figure out how hard to throw the banana but
        // adjust it by dividing velocity by 10
        let speed = Double(velocity) / 10.0
        
        // convert the input angle to radians
        let radians = deg2rad(degrees: angle)
        
        // if there is already a banana remove it
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        // and create a new one using circle physics
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionType.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        // perform collision calculations between frames
        // at the cost of some speed.
        // it's good for small objects that are fast moving
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        // if player1 was throwing the banana, then
        // position it up and to the left of the player
        // and give it some spin
        if currentPlayer == 1 {
            // subtract 30 from x and add 40 to y
            // so that the player doesn't hit itself
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            // animate player1 throwing their arm up, a short pause,
            // and then put it back down
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            // make the banana move in the correct direction
            // if we calculate the cosine of our angle in radians
            // it will tell us how much horizontal momentum to apply,
            // and if we calculate the sine of our angle in radians
            // it will tell us how much vertical momentum to apply.
            // once that momentum is calculated, we multiply it by
            // the velocity we calculated (or negative velocity in
            // the case of being player 2, because we want to throw
            // to the left), and then turn it into a CGVector.
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            // push the banana in the right direction
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20

            // animate the throw
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)

            // - speed so the banana moves to the left
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        // there are several possible kinds of a collision involving bananas:
        // 1. banana hit building - affect building
        // 2. building hit banana - affect building
        // 3. banana hit player1 - affect player1
        // 4. player1 hit banana - affect player1
        // 5. banana hit player2 - affect player2
        // 6. player2 hit banana - affect player2
        
        // half of these cases are the same so they can
        // be reduced down to three cases.
        
        // the CollisionType enum has these cases:
        //    case banana = 1
        //    case building = 2
        //    case player = 4

        // because of how the enums values are set we can compare
        // bodyA to bodyB and get the results we want.
        // if bodyA is a banana and bodyB is a building or a player
        // then we will assign the bodies the same way.
        // if bodyA is a building and bodyB is a player
        // then we will assign the bodies as represented.
        // if bodyA is a player and bodyB is a banana or a building
        // then we will assign the bodies as represented.
        // we don't care about either player hitting any building,
        // so we only have to compare categoryBitMask of enum
        // values of 1 vs 2 or 1 vs 4
        // and we don't care about 2 vs 4
        
        // when assigning values to firstBody/secondBody, the
        // firstBody will always have the lower number and
        // the secondBody will always have the higher number.
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            // if the contact is between banana and building
            // then firstBody is banana and secondBody is building.
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            // if the contact is between building and banana
            // then firstBody is banana and secondBody is building.
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // we need to unwrap these because .node might be nil
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }

        // banana hit building
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        // banana hit player1
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        }
        
        // banana hit player2
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        }
    }

    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        
        // convert the collision contact point into the coordinates
        // relative to the building node.
        // if the building node was at x:200 and the collision was at
        // x:250, then it will return x:50 because it was 50 points
        // into the building now.
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        // this is to fix a small bug.
        // if a banana happens to hit two buildings at the same time,
        // then it will explode twice and also call changePlayer()
        // twice. by clearing the banana's name, the second collision
        // won't happen because the didBegin() method won't see the
        // banana as being a banana anymore (because the name is blank).
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func destroy(player: SKSpriteNode) {

        print("in destroy player")
        print("  current player number is \(currentPlayer)")
        print("  player hit was \(String(describing: player.name))")
        // create an explosion
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        // remove the destroyed player and banana
        player.removeFromParent()
        banana.removeFromParent()

        // if the player hit was player 1 then award points
        // to player 2
        if player == player1 {
            // add one to player 2 score
            viewController?.playerScored(player: 2)
            print("  added 1 to player 2 score")
            
            // and subtract a life from player 1
            player1NumLives -= 1
            print("  subtracted 1 from player 1 num lives")
            print("  player 1 num lives = \(player1NumLives)")
            print("  hiding player 1 lives nodes at position \(player1NumLives)")
            player1LivesNodes[player1NumLives].isHidden = true
            print("  hid \(player1LivesNodes[player1NumLives].name) node")
            
        } else {
            // add one to player 1 score
            viewController?.playerScored(player: 1)
            print("  added 1 to player 1 score")
            
            player2NumLives -= 1
            print("  subtracted 1 from player 2 num lives")
            print("  player 2 num lives = \(player2NumLives)")
            
            // there's probably a better way to do this.
            // for player 1, hide sprite starting with the
            // right-most sprite.
            // for player 2, start with the left-most sprite.
            var player2ArrayPosition = 0
            if player2NumLives == 2 {
                player2ArrayPosition = 0
            } else if player2NumLives == 1 {
                player2ArrayPosition = 1
            } else if player2NumLives == 0 {
                player2ArrayPosition = 0
            } else {
                print("  something went wrong setting player2ArrayPosition")
            }
            
            print("  hiding player 2 lives nodes at position \(player2ArrayPosition)")
            player2LivesNodes[player2ArrayPosition].isHidden = true
            print("  hid \(player2LivesNodes[player2ArrayPosition].name) node")
        }
        
        print("  before async, player1LivesNodes.count = \(player1LivesNodes.count)")
        print("  before async, player2LivesNodes.count = \(player2LivesNodes.count)")

        // show a transition scene to end the game
        // wait for 2 seconds to display the new scene
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // we want a strong self here
            let newGameScene = GameScene(size: self.size)
            // update the view controller's currentGame property
            // and set the new scene's viewController property
            // so they can talk to each other.
            newGameScene.viewController = self.viewController
            self.viewController?.currentGame = newGameScene
            
            // transfer control of the game to the other player
            self.changePlayer()
            newGameScene.currentPlayer = self.currentPlayer
            
//            let transition = SKTransition.doorway(withDuration: 1.5)
//            let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.5)
//            let transition = SKTransition.fade(withDuration: 1.5)
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.5)
            self.view?.presentScene(newGameScene, transition: transition)
            
            self.viewController?.resetSliderValues()
        }
    }
     
    func changePlayer() {
        currentPlayer = currentPlayer == 1 ? 2 : 1
        
        viewController?.activatePlayer(for: currentPlayer)
    }

    override func update(_ currentTime: TimeInterval) {
        // if a thrown banana is off the screen and doesn't
        // hit a player or building, then remove it and
        // change players.
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }

}
