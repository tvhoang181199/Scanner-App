//
//  MainViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 02/12/2020.
//

import UIKit
import ObjectMapper



class MainViewController: UITabBarController {

    private var popGesture: UIGestureRecognizer?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.tabBarController?.navigationItem.leftItemsSupplementBackButton = true
        

        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        ManageCacheObject.setTabIndex(self.selectedIndex)
    }
    
}
