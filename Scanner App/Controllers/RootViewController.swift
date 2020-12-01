//
//  RootViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 28/11/2020.
//

import UIKit


class RootViewController: BaseViewController, NavigationControllerCustomDelegate {

    var baseNavigationController: NavigationControllerCustom!
    var mainViewController:ViewController?
    let centerPanelExpandedOffset: CGFloat = UIScreen.main.bounds.width - 80

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mainViewController = UIStoryboard.viewController()
        baseNavigationController = NavigationControllerCustom(rootViewController: mainViewController!)
        view.addSubview(baseNavigationController.view)
        baseNavigationController.didMove(toParent: self)
        baseNavigationController.touchTarget = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.rotation), name: NSNotification.Name(rawValue: "AddNotificationRotation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.removeRotation), name: NSNotification.Name(rawValue: "RemoveNotificationRotation"), object: nil)
        
    }

    @objc func rotation(){
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    @objc func removeRotation(){
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
}

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
}
