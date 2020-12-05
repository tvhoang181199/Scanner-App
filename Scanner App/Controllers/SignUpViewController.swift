//
//  SignUpViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 01/12/2020.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import JGProgressHUD

class SignUpViewController : UIViewController, NavigationControllerCustomDelegate {
    
    @IBOutlet weak var txt_firstName: UITextField!
    @IBOutlet weak var txt_lastName: UITextField!
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
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:false, hideFilterButton:true, title: "")
        navigationControllerCustom.navigationBar.barTintColor = ColorUtils.toolbar()
        navigationControllerCustom.navigationBar.isHidden = false
//        self.navigationItem.hidesBackButton = true
    }
    
    func backTap() {
        navigationController?.popViewController(animated: true)
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
    
    @IBAction func btn_signUp(_ sender: Any) {
        if txt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_lastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            txt_password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            Toast.show(message: "Please fill out all field!", controller: self)
            return
        }
        
        let cleanedPassword = txt_password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utils.isPasswordValid(cleanedPassword) == false {
            Toast.show(message: "Please ensure that password has at least 8 characters, contains a special character and a number!", controller: self)
            return
        }
        
        let hud = JGProgressHUD()
        hud.textLabel.text = "On the way..."
        hud.show(in: self.view)
        
        Auth.auth().createUser(withEmail: txt_email.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: txt_password.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (result, err) in
            if err != nil {
                Toast.show(message: "Error creating user!", controller: self)
                hud.dismiss()
            }
            else {
                let db = Firestore.firestore()
                db.collection("documents").document(self.txt_email.text!.trimmingCharacters(in: .whitespacesAndNewlines)).setData([:]) {(error) in}
                db.collection("users").addDocument(data: [
                    "first_name":self.txt_firstName.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                    "last_name":self.txt_lastName.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                    "password":self.txt_password.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                    "email":self.txt_email.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                    "uid":result!.user.uid
                ]) { (error) in
                    if error != nil {
                        Toast.show(message: "Error saving user!", controller: self)
                        hud.dismiss()
                    }
                    else {
                        hud.dismiss()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}

