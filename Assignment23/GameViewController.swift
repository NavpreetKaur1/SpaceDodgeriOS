
import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var skView: SKView?
    var gameScene: GameScene?
    @IBOutlet weak var PlayDaGame: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView = self.view as? SKView
        skView?.showsFPS = true
        skView?.showsNodeCount = false
        skView?.ignoresSiblingOrder = true
        
       //skView?.size = skView.bounds.size
       // skView?.scaleMode = .ScaleToFit;
        
        /* Set the scale mode to scale to fit the window */
       // skView.size = skView.bounds.size
       // skView.scaleMode = .AspectFit;
        startGame()
    }
    func startGame() {
        gameScene = GameScene(size: self.view.frame.size)
        gameScene?.scaleMode = .aspectFill
        skView?.presentScene(gameScene)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue)
    {
        
    }

}
