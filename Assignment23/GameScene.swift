/*
 Made by Sarthak Sharma, Navpreet Kaur and Jeanice Nguyen
This class contains all the game logic for the UFO game. It contains method for the HUD, gameplay logic, score logic, rendering logic
 */
import SpriteKit
import GameplayKit

let collisionBulletCategory: UInt32  = 0x1 << 0
let collisionHeroCategory: UInt32    = 0x1 << 1

class GameScene: SKScene, SKPhysicsContactDelegate, Alertable {
    
    //Testing game with two background images
    var background1 = SKSpriteNode(imageNamed: "UFOBackground.jpg")
    var background2 = SKSpriteNode(imageNamed: "space.jpg")
    let delay = SKAction.wait(forDuration: 5.0)
    //UFO is the Hero in our game
    let ufo = SKSpriteNode(imageNamed: "ufo123.png")
    
    //Missile is the enemy in this game
    let missile = SKSpriteNode(imageNamed: "missileT.png")
    let missileSpeed:CGFloat = 3.0
    var nodePosition = CGPoint()
    var startTouch = CGPoint()
    var gamePaused = false
    
    //Call enemy missiles from
    var enemySprites = MissileSpriteController()
    var invisibleControllerSprite = SKSpriteNode()
    
    //Variables for various HUD elements
    var lifeNodes : [SKSpriteNode] = []
    var remainingLifes = 3
    var scoreNode = SKLabelNode()
    var score = 0
    
    override func didMove(to view: SKView) {
        
        ufo.xScale = 2.50
        ufo.yScale = 2.50
        ufo.position = CGPoint(x: self.frame.width/1.5, y: self.frame.height/1.5)
        
        //collision detection for the ufo
        ufo.physicsBody?.isDynamic = true
        ufo.physicsBody = SKPhysicsBody(texture: ufo.texture!, size: ufo.size)
        ufo.physicsBody?.affectedByGravity = false
        ufo.physicsBody?.categoryBitMask = collisionHeroCategory
        ufo.physicsBody?.contactTestBitMask = collisionBulletCategory
        
        ufo.physicsBody?.collisionBitMask = 0x0
        
        self.addChild(ufo)
        /*
        *Some other physics properties not being used ATM
        *but cool to play around with
        */
        //ufo.physicsBody?.restitution = 1
        //ufo.physicsBody?.friction = 0
        //ufo.physicsBody = SKPhysicsBody(circleOfRadius: ufo.size.width / 2.0)
        //ufo.size = CGSize(width: 250, height: 250)
        //ufo.physicsBody?.restitution = 1
        //ufo.physicsBody?.friction = 0
        
        //Limit game objects to the screen boundry
        //self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        /*
        * Not using big missile for the project
        */
        missile.size = CGSize(width: 250, height: 250)
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.size.width / 2.0)
        missile.physicsBody?.affectedByGravity = false
        missile.physicsBody?.isDynamic = true
        //self.addChild(missile)
        
        /*
        * Test properties of the UFO
        */
        //missile physics properties
        //missile.physicsBody?.restitution = 1
        //missile.physicsBody?.friction = 0
        
        //set postion of ufo and missiles on load
        //ufo.position = CGPoint(x: size.width/2, y: size.height/2)
        //missile.position = CGPoint(x: frame.midX + 20, y: frame.midY + 20)
        
        // Define invisible sprite for rotating and steering behavior without trigonometry
        invisibleControllerSprite.size = CGSize(width: 0, height: 0)
        self.addChild(invisibleControllerSprite)
        
        // Define Constraint for the orientation behavior
        let rangeForOrientation = SKRange(constantValue: CGFloat(M_2_PI*7))
        ufo.constraints = [SKConstraint.orient(to: invisibleControllerSprite, offset: rangeForOrientation)]
        
        
        //Show the missiles after a 5 second delay
        run(delay) {
            //number of enemies to spawn
            for _ in 1...10 {
                self.addChild(self.enemySprites.spawnEnemy(targetSprite: self.ufo)) //targetSprite could be missile as well
            }
        }

        //set background attributes when teh game launches
        background1.zPosition = -1
        background2.zPosition = -1
        background2.size.height = self.size.height
        background2.size.width = self.size.width
        background2.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        //addChild(background1)
        addChild(background2)
        
        
        //Keep Enemy Missiles from vanishing off screen
        let width2 =  missile.size.width/2
        let height2 =  missile.size.height/2
        let xRange = SKRange(lowerLimit:0+width2,upperLimit:size.width-width2)
        let yRange = SKRange(lowerLimit:0+height2,upperLimit:size.height-height2)
        missile.constraints = [SKConstraint.positionX(xRange,y:yRange)]
        //Keep player UFO from vanishing off screen
        let width3 =  ufo.size.width/2
        let height3 =  ufo.size.height/2
        let xRange1 = SKRange(lowerLimit:0+width2,upperLimit:size.width-width3)
        let yRange1 = SKRange(lowerLimit:0+height2,upperLimit:size.height-height3)
        ufo.constraints = [SKConstraint.positionX(xRange1,y:yRange1)]
        
        //Add the hud
        MakeTheHUD()
        
        self.physicsWorld.contactDelegate = self
    }
    
    /*
    * This method create the HUD on the game screen.  It adds three UFO lives images on the top left of the sreen.  The player score is displayed on the top right of the screen
    */
    func MakeTheHUD() {
        
        let hud = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.size.width, height: self.size.height*0.05))
        hud.anchorPoint=CGPoint(x: 0, y: 0)
        hud.position = CGPoint(x: 0, y: self.size.height-hud.size.height)
        self.addChild(hud)
        
        //Add remaining lives
        let lifeSize = CGSize(width: hud.size.height-10, height: hud.size.height-10)
        
        /*
        *Add three lifes for the UFO on top left of the screen
        */
        for i in 0 ..< self.remainingLifes {
            let tmpNode = SKSpriteNode(imageNamed: "ufo123")
            lifeNodes.append(tmpNode)
            tmpNode.size = lifeSize
            tmpNode.position=CGPoint(x: tmpNode.size.width * 1.3 * (1.0 + CGFloat(i)), y: (hud.size.height-5)/2)
            hud.addChild(tmpNode)
        }
        
        /*
        *Display Player score on the top right of the screen
        */
        self.score = 0
        self.scoreNode.position = CGPoint(x: hud.size.width-hud.size.width * 0.1, y: 1)
        self.scoreNode.text = "0"
        self.scoreNode.color = SKColor.white
        self.scoreNode.fontSize = 80
        hud.addChild(self.scoreNode)
        
    }
    /*
    * Add smoking effect to UFO once its damaged
    */
    func smokeyUFO(pos: CGPoint) {
        let emitter = SKEmitterNode(fileNamed: "SmokeItUp")
        emitter?.particlePosition = pos
        self.addChild(emitter!)
        self.run(SKAction.wait(forDuration: 2), completion: { emitter?.removeFromParent() })
    }
    
    /*
    * Blow up the UFO when the HP is depleted
    */
    func blowMeUp(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: "ExplosionX.sks")
            emitterNode?.particlePosition = pos
        self.addChild(emitterNode!)
        self.run(SKAction.wait(forDuration: 2), completion: { emitterNode?.removeFromParent() })
    }
    /*
    *Collision detection method for bullet and ufo if they collide
    *call the explosion method (blowMeUp) and lifeLost()
    *Also reset the score to 0
    */
    func didBegin(_ contact: SKPhysicsContact) {
        if !self.gamePaused {
            smokeyUFO(pos: self.ufo.position)
            blowMeUp(pos: self.ufo.position)
            lifeLost()
            // reset score
            self.score=0
            self.scoreNode.text = String(0)
        }
    }
    /*
    *Method launches when the user touches panel
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if (node.name == "PauseButton") || (node.name == "PauseButtonContainer") {
                showPauseAlert()
            } else {
            
                // Determine the new position for the invisible sprite:
                // The calculation is needed to ensure the positions of both sprites
                // are nearly the same, but different. Otherwise the hero sprite rotates
                // back to it's original orientation after reaching the location of
                // the invisible sprite
                var xOffset:CGFloat = 1.0
                var yOffset:CGFloat = 1.0
                if location.x>ufo.position.x {
                    xOffset = -1.0
                }
                if location.y>ufo.position.y {
                    yOffset = -1.0
                }
                
                // Create an action to move the invisibleControllerSprite.
                // This will cause automatic orientation changes for the hero sprite
            let actionMoveInvisibleNode = SKAction.move(to: CGPoint(x: location.x - xOffset, y: location.y - yOffset), duration: 0.2)
                invisibleControllerSprite.run(actionMoveInvisibleNode)
                
                // Create an action to move the hero sprite to the touch location
            let actionMove = SKAction.move(to: location, duration: 1)
                ufo.run(actionMove)
        }
        }
    }

    //touches moved method move the ufo when the player touches it
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch = touches.first
        if let location = touch?.location(in: self){

            ufo.run(SKAction.move(to: CGPoint(x:  nodePosition.x + location.x - startTouch.x, y: nodePosition.y + location.y - startTouch.y), duration: 0.1))

            let dx = ufo.position.x - missile.position.x
            let dy = ufo.position.y - missile.position.y
            let angle = atan2(dy, dx)
            
            missile.zRotation = angle
            missile.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 50))
        }
    }
    //In this method, once the life is lost a game over alert is launched and all actions from the ufo are removed
    func lifeLost() {
        //if game is lost pause the game
        self.gamePaused = true

        // remove one life from hud
        if self.remainingLifes>0 {
            self.lifeNodes[remainingLifes-1].alpha=0.0
            self.remainingLifes -= 1
        }
        
        // check if remaining lifes exists
        if (self.remainingLifes==0) {
            //launch Alert
            let alertController = UIAlertController(title: "Game Over", message: "Game Over Try Again", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            //Alert pop does not appear
            //self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            //self.presentViewController(alertController, animated: true, completion: nil)
            print("launch life lost gameOverAlert")
            showGameOverAlert()
        }
        
        // Stop movement, fade out, move to center, fade in
        ufo.removeAllActions()
        self.ufo.run(SKAction.fadeOut(withDuration: 1) , completion: {
            self.ufo.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
            self.ufo.run(SKAction.fadeIn(withDuration: 1), completion: {
            self.gamePaused = false
            })
        })
    }

    // Show Pause Alert
    func showPauseAlert() {
        self.gamePaused = true
        
        showAlert(withTitle: "Test Message", message: "Alert message")

        
//        let alert = UIAlertController(title: "Pause", message: "", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default)  { _ in
//            self.gamePaused = false
//        })
//        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    //This method generates the smoke effect for the ufo
    func bulletEffects(pos: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: "CrazySmokeEffect.sks")
        emitterNode?.particlePosition = pos
        self.addChild(emitterNode!)
        self.run(SKAction.wait(forDuration: 2), completion: { emitterNode?.removeFromParent() })
    }
    //show the game over alert when the game is over
    func showGameOverAlert() {
        print("Launch game over Alert Method")
        self.gamePaused = true
        
        let alert = UIAlertController(title: "Game Over", message: "", preferredStyle: UIAlertControllerStyle.alert)
         showAlert(withTitle: "Game Over Test", message: "Game over message")
   
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default)  { _ in
            
            // restore lifes in HUD
            self.remainingLifes=3
            for i in 1...3 {
                self.lifeNodes[i].alpha=1.0
            }
            
            // reset score
            self.score=0
            self.scoreNode.text = String(0)
        })
        
        // show alert
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    var _dLastShootTime: CFTimeInterval = 1
    override func update(_ currentTime: TimeInterval) {
 
    if !self.gamePaused {
        if currentTime - _dLastShootTime >= 1 {
            enemySprites.shoot(targetSprite: ufo)
            _dLastShootTime=currentTime
            
            // Increase score
            self.score += 1
            self.scoreNode.text = String(score)
        }
    }
    }

}

