//
//  GameViewController.swift
//  Project29
//
//  Created by Robert Hoover on 2023-05-19.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var currentGame: GameScene?
    
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!

    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!

    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    
    @IBOutlet var player1ScoreLabel: UILabel!
    @IBOutlet var player2ScoreLabel: UILabel!
    
    var player1Score = 0 {
        didSet {
            player1ScoreLabel.text = "Score: \(player1Score)"
        }
    }
    var player2Score = 0 {
        didSet {
            player2ScoreLabel.text = "Score: \(player2Score)"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player1Score = 0
        player2Score = 0

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                // set the currentGame property to the initial
                // game scene so we can start using it.
                currentGame = scene as? GameScene
                // make sure that the reverse is true so that
                // the scene knows about the view controller.
                currentGame?.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = false
        }
        
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
    }

    
    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: UIButton) {
        toggleHiddenUIElements(with: true)
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    func activatePlayer(for number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
            playerNumber.textAlignment = .left
        } else {
            playerNumber.text = "PLAYER TWO >>>"
            playerNumber.textAlignment = .right
        }
        
        toggleHiddenUIElements(with: false)
    }
    
    func toggleHiddenUIElements(with value: Bool) {
        angleSlider.isHidden = value
        angleLabel.isHidden = value
        velocitySlider.isHidden = value
        velocityLabel.isHidden = value
        launchButton.isHidden = value

        player1ScoreLabel.isHidden = value
        player2ScoreLabel.isHidden = value
    }


    func playerScored(player: Int) {
        if player == 1 {
            player1Score += 1
            
        }
        else {
            player2Score += 1
        }
    }
    
    func resetSliderValues() {
        angleSlider.value = 45
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
        velocitySlider.value = 125
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
