//
//  SignUpViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 01/12/2020.
//

import UIKit

class SignUpViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var txt_firstName: UITextField!
    @IBOutlet weak var txt_lastName: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:false, hideFilterButton:true, title: "")
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        self.navigationItem.hidesBackButton = true
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_signUp(_ sender: Any) {
        
    }
}

