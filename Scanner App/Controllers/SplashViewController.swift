//
//  SplashViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit
import ObjectMapper

class SplashViewController: UIViewController ,NavigationControllerCustomDelegate{
    
    var window: UIWindow?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMainScreen()
    }

   
    func getConfig(){
        
    }
    
    func loadMainScreen(){
        self.view.removeFromSuperview()
        let frame = UIScreen.main.bounds
        self.window = UIWindow(frame: frame)
        self.window!.rootViewController = RootViewController()
        self.window!.makeKeyAndVisible()
    }
    
    func registerDevice(){
        
    }
}

