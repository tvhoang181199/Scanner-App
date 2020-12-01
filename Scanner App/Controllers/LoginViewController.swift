//
//  LoginViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 29/11/2020.
//

import Foundation
import UIKit
import FirebaseAuth

class LoginViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "")
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        self.navigationItem.hidesBackButton = false
    }

    @IBAction func btn_sigUp ( _ sender:Any) {
        let signUpViewController:SignUpViewController?
        signUpViewController = UIStoryboard.signUpViewController()
        navigationController?.pushViewController(signUpViewController!, animated: true)
    }
    
    @IBAction func btn_signIn(_ sender: Any) {
        
    }
}
