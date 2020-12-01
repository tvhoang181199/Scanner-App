//
//  StoryboardManager.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import Foundation
import UIKit

extension UIStoryboard {
    
//    ============== define Main Storyboard ===============
    
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    class func loginViewController() -> LoginViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
    }
    
    class func signUpViewController() -> SignUpViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
    }
    
    class func viewController() -> ViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ViewController") as? ViewController
    }
}
