//
//  StoreDataViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 02/12/2020.
//

import UIKit
import JGProgressHUD

class StoreDataViewController : UIViewController, NavigationControllerCustomDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "DATA")
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        self.navigationItem.hidesBackButton = true
    }
    
}
