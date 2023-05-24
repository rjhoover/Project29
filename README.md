### From Hacking With Swift - [100 Days of Swift](https://www.hackingwithswift.com/100/) (UIKit edition)
## [Project29](https://www.hackingwithswift.com/100/94) Gorillas

## [Challenge](https://www.hackingwithswift.com/read/29/6/wrap-up)

1. Add code and UI to track the player scores across levels, then make the game end after one player has won three times.

I'm working on the first challenge for this project to track scores and I wanted to have a 'game over' feature when one of the players lost three lives. I thought I'd get a little fancy and use tiny gorillas for the number of lives left then hide them when one was lost. This basically works. 

What doesn't work is that, when I present the screen after a life is lost, it's triggering **didMove(to:)** which, somehow, is resetting the arrays **player1LivesNodes** and **player2LivesNodes**. 

This causes the **createLives()** method to recreate the two arrays from scratch. In the **createLives()** method, I do a test to see if both of the arrays are empty and only if they are empty do I create the nodes and add them to the arrays (for each player).

I have some properties set up to track number of lives per player. I keep arrays of each node created for each player in its own array.

```
    // variables to track the number of lives left during game play
    var player1NumLives: Int = 3
    var player2NumLives: Int = 3
    
    // arrays to store nodes for each of the player lives sprites
    var player1LivesNodes = [SKSpriteNode]()
    var player2LivesNodes = [SKSpriteNode]()
```

And I have the **didMove(to:)** method which calls the function **createLives()** to populate the two arrays above.

```
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

```

In the **createLives()** function, I first test to see if both of the arrays of nodes for the players lives are empty or not. If they are empty, then I know I should create each node and populate the array for each player.
If they are not empty, then I assume that I've already created the nodes and populated the arrays. Here's that function:

```
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
    
```


In the **destroy(player:)** function I check to see which player was destroyed, add to the score, subtract a life from the destroyed player, then set **isHidden** to true on the node from the appropriate array

```
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
```


Here's the output from running the program on a real iPad:


> **in didMove to**
>   before createLives, player1LivesNodes.count = 0
>   before createLives, player2LivesNodes.count = 0
>   
> **in createLives**
>   starting out, player1LivesNodes.count = 0
>   starting out, player2LivesNodes.count = 0
>   arrays are both empty, creating lives nodes
>   at end, player1LivesNodes.count = 3
>   at end, player2LivesNodes.count = 3
>   
> **in destroy player**
>   current player number is 1
>   player hit was Optional("player2")
>   added 1 to player 1 score
>   subtracted 1 from player 2 num lives
>   player 2 num lives = 2
>   hiding player 2 lives nodes at position 0
>   hid Optional("player2Life0") node
>   before async, player1LivesNodes.count = 3
>   before async, player2LivesNodes.count = 3
>   
> **in didMove to**
>   before createLives, player1LivesNodes.count = 0
>   before createLives, player2LivesNodes.count = 0
>   
> **in createLives**
>   starting out, player1LivesNodes.count = 0
>   starting out, player2LivesNodes.count = 0
>   arrays are both empty, creating lives nodes
>   at end, player1LivesNodes.count = 3
>   at end, player2LivesNodes.count = 3


You can see that **createLives()** is called from **didMove(to:)** and that **createLives()** is creating the sprites and adding them to the **player[12]LivesNodes** arrays. 
You can't see this, but the sprites are being added to the screen properly.
In **destroy(player:)** it properly destroys the player hit, adds 1 to the score, subtracts 1 from **player[12]NumLives**, hides the sprite node (and it is hidden from the screen).
In the async code, a new game scene is being created, a transition is created, and the new scene is presented using the transition.
Presenting the scene causes **didMove(to:)** to fire, which in turn calls **createLives()**.

The problem is that, when **didMove(to:)** fires, the **player[12]LivesNodes** arrays are reset somehow and, because they're both empty, new nodes are created and added to the arrays. I can't figure out what or why this is happening.
