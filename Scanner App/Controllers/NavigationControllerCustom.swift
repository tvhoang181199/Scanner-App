//
//  NavigationControllerCustom.swift
//  Scanner App
//
//  Created by Gia Huy on 29/11/2020.
//

import Foundation
import UIKit

@objc protocol NavigationControllerCustomDelegate {
    @objc optional func backTap()
    @objc optional func filterTap()
}

class NavigationControllerCustom: UINavigationController {

    var backButton : UIButton!
    var filterButton : UIButton!
    var touchTarget : NavigationControllerCustomDelegate?
    var textTitle : UILabel!
    var backGroundView:UIView!
    var heightNavigationBar : CGFloat = 0
    var heightButton : CGFloat = 20
    var fontSizeButton : CGFloat = 25
    var widthButton : CGFloat = 30
    var setTopAction : Bool = false
    var isMenuHidden = true
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
    
    func setUpView() {
        
            let heightNavi = self.navigationBar.frame.size.height
            let widthNavi = self.navigationBar.frame.size.width
            let statusBarSize = UIApplication.shared.statusBarFrame.size
            heightNavigationBar = heightNavi + statusBarSize.height

            self.navigationItem.hidesBackButton = true
            self.navigationBar.barTintColor = ColorUtils.toolbar()
            let viewBackground = UIView(frame: CGRect(x: 0, y: -45, width: widthNavi, height: heightNavi+45))
            viewBackground.backgroundColor = ColorUtils.toolbar()
            self.navigationBar.addSubview(viewBackground)
            
            textTitle = UILabel(frame: CGRect(x: widthNavi/2 - (widthNavi - 80)/2, y: 0, width: widthNavi - 80, height: heightNavi))
            textTitle.backgroundColor = UIColor.clear
            textTitle.textColor = UIColor.white
            textTitle.textAlignment = NSTextAlignment.center
            textTitle.font = UIFont(name: "Helvetica-Bold", size: 18)
            textTitle.isUserInteractionEnabled = true
            self.navigationBar.addSubview(textTitle)
         

            
            backButton = UIButton(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
            backButton?.showsTouchWhenHighlighted = true
            
            if let image = UIImage(named: "icon_back") {
                backButton.setImage(image, for: .normal)
                backButton.tintColor = UIColor.white
            }
            backButton.setTitleColor(UIColor.white, for: UIControl.State())
            backButton.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
            backButton.addTarget(self, action:#selector(NavigationControllerCustom.backTap), for: UIControl.Event.touchUpInside)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            self.navigationBar.addSubview(backButton)
        
            
            
            
            filterButton = UIButton(frame: CGRect(x: widthNavi - 50, y: 0, width: 30, height: 30))
            filterButton?.showsTouchWhenHighlighted = true
            if let image = UIImage(named: "baseline_filter_list_black_48pt") {
                filterButton.setImage(image, for: .normal)
            }
            
            filterButton.setTitleColor(UIColor.white, for: UIControl.State())
            filterButton.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
            filterButton.tintColor = UIColor.white
            filterButton.addTarget(self, action:#selector(NavigationControllerCustom.filterTap), for: UIControl.Event.touchUpInside)
            filterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            self.navigationBar.addSubview(filterButton)
            
            


            backButton.isHidden = true
            textTitle.isHidden = true
            filterButton.isHidden = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    func add(){

    }
    
    func remove(){
       
    }
    
    func setUpNavigationBar(_ target:NavigationControllerCustomDelegate, hideBackButton:Bool, hideFilterButton:Bool, title:String){
        
        setUpView()
        
        self.touchTarget = target
        self.backButton.isHidden = hideBackButton
        self.filterButton.isHidden = hideFilterButton
        
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
       
    }
    
    
    
    func setTitleHeader(_ title : String){
        if(title != ""){
            self.textTitle.isHidden = false
            self.textTitle.text = title
        }else{
            self.textTitle.isHidden = true
        }
    }

    func navigationController(_ navigationController: UINavigationController, willShow: UIViewController, animated: Bool){
    
    }
  
   @objc func backTap(){
        debugPrint("back Tap")
        touchTarget?.backTap!()
    }
    
    @objc func filterTap(){
        debugPrint("filter Tap")
        touchTarget?.filterTap!()
    }
    
}
