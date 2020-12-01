//
//  LoginViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 29/11/2020.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import JGProgressHUD
import ObjectMapper

class LoginViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "")
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        self.navigationItem.hidesBackButton = false
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height * (2/3)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func btn_sigUp ( _ sender:Any) {
        let signUpViewController:SignUpViewController?
        signUpViewController = UIStoryboard.signUpViewController()
        navigationController?.pushViewController(signUpViewController!, animated: true)
    }
    
    @IBAction func btn_signIn(_ sender: Any) {
        
        let hud = JGProgressHUD()
        hud.textLabel.text = "Please wait..."
        hud.show(in: self.view)
        
        let email = txt_email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = txt_password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                Toast.show(message: error!.localizedDescription, controller: self)
                hud.dismiss()
            }
            else {
                
//                let account = Account()
//                account.firstName = ""
//                account.lastName = ""
//                account.email = email
                
                let db = Firestore.firestore()
                
                let docRef = db.collection("users").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        
                        let document = querySnapshot!.documents.first
                        let account = Mapper<Account>().map(JSONObject: document!.data())!
                        ManageCacheObject.saveCurrentAccount(account)
                        
                        let mainViewController:MainViewController?
                        mainViewController = UIStoryboard.mainViewController()
                        self.navigationController?.pushViewController(mainViewController!, animated: true)
                        hud.dismiss()
                    }
                }
                
                

            }
        }
        
    }
}
