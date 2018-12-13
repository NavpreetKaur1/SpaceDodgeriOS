/*
 Made by Jeanice Nguyen
 This class contains code for alert box, which is launched in the gamescene as needed
 */
import Foundation
import SpriteKit

protocol Alertable { }
extension Alertable where Self: SKScene {
    
    func showAlert(withTitle title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(okAction)
        
        view?.window?.rootViewController?.present(alertController, animated: true)
    }
    
}
