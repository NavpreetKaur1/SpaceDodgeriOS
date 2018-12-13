/*
 Made by Sarthak Sharma
 This class contains all the game logic for the bullet and missiles that follow the ufo, the class is instantiate inside the GameScene.sks
 */
import Foundation
import SpriteKit


class MissileSpriteController {
    var enemySprites: [SKSpriteNode] = []
  
 /*
 *This method renders the missile object that chases the player using the missileT.png
     Method is instantiate inside the gameScene class
 */
func spawnEnemy(targetSprite: SKNode) -> SKSpriteNode {
    
    // create a new enemy sprite
    let newEnemy = SKSpriteNode(imageNamed:"missileT.png")
    enemySprites.append(newEnemy)
    
    newEnemy.xScale = 0.10
    newEnemy.yScale = 0.10

    let sizeRect = UIScreen.main.bounds
    let posX = arc4random_uniform(UInt32(sizeRect.size.width))
    let posY = arc4random_uniform(UInt32(sizeRect.size.height))
    newEnemy.position = CGPoint(x: CGFloat(posX), y: CGFloat(posY))
    
    // Define Constraints for orientation/targeting behavior
    let i = enemySprites.count-1
    let rangeForOrientation = SKRange(constantValue:CGFloat(M_2_PI*7))
    let orientConstraint = SKConstraint.orient(to: targetSprite, offset: rangeForOrientation)
    let rangeToSprite = SKRange(lowerLimit: 80, upperLimit: 90)
    var distanceConstraint: SKConstraint
    
    // First enemy has to follow spriteToFollow, second enemy has to follow first enemy, ...
    if enemySprites.count-1 == 0 {
        distanceConstraint = SKConstraint.distance(rangeToSprite, to: targetSprite)
    } else {
        distanceConstraint = SKConstraint.distance(rangeToSprite, to: enemySprites[i-1])
    }
    newEnemy.constraints = [orientConstraint, distanceConstraint]
    
    return newEnemy
    }
    
    /*
    *This method creates bullet object for the enemy missiles
     After the bullets are created it tarets the ufo/player object
    */
    func shoot(targetSprite: SKNode) {
        // var x = 0
        for enemy in enemySprites {
            let bullet = SKSpriteNode()
            //x += 1
            //print("ufo was hit value of x is")
            //print(x)
            bullet.color = UIColor.green
            bullet.size = CGSize(width: 10,height: 10)
            bullet.position = CGPoint(x: enemy.position.x, y: enemy.position.y)
            targetSprite.parent?.addChild(bullet)
            
            // Add physics body for collision detection
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
            bullet.physicsBody?.isDynamic = true
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = collisionBulletCategory
            bullet.physicsBody?.contactTestBitMask = collisionHeroCategory
            bullet.physicsBody?.collisionBitMask = 0x0
            
            // Determine vector to targetSprite
            let vector = CGVector(dx: (targetSprite.position.x-enemy.position.x), dy: targetSprite.position.y-enemy.position.y)
        
            // Create the action to move the bullet. Don't forget to remove the bullet!
            let bulletAction = SKAction.sequence([SKAction.repeat(SKAction.move(by: vector, duration: 1), count: 10) ,  SKAction.wait(forDuration: 30.0/60.0), SKAction.removeFromParent()])
            bullet.run(bulletAction)
        }
    }
}
