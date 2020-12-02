//
//  ViewController.swift
//  Scanner App
//
//  Created by Trịnh Vũ Hoàng on 20/11/2020.
//

import UIKit


class ViewController:  UIViewController, NavigationControllerCustomDelegate {

    var window: UIWindow?
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        if (ManageCacheObject.isLogin()) {
            let mainViewController:MainViewController?
            mainViewController = UIStoryboard.mainViewController()
            self.navigationController?.pushViewController(mainViewController!, animated: false)
            
        }
        else {
            let loginViewController: LoginViewController?
            loginViewController = UIStoryboard.loginViewController()
            self.navigationController!.pushViewController(loginViewController!, animated: false)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
 
}

