//
//  ProfileViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 02/12/2020.
//

import UIKit
import Foundation
import VisionKit
import JGProgressHUD
import SCLAlertView
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol UploadDocumentProtocol {
    func didUploadNewDocument()
}

class ProfileViewController : UIViewController, NavigationControllerCustomDelegate, VNDocumentCameraViewControllerDelegate {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let currentUser = Auth.auth().currentUser
    
    var listener: UploadDocumentProtocol!
    
    @IBOutlet weak var helloLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helloLabel.text = "Hello, \((currentUser?.email)!)!"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "PROFILE")
        navigationControllerCustom.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func scanButtonTapped(_ sender: Any) {
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = self
        self.present(scannerVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let dialogConfirmViewController:DialogConfirmViewController?
        dialogConfirmViewController = UIStoryboard.dialogConfirmViewController()
        dialogConfirmViewController?.delegate = self
        self.present(dialogConfirmViewController!, animated: true, completion: nil)
        
    }
    
    func getCurrentTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: Date())
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var documentName:String? = nil
        var documentData:[String:Any] = [:]
        let currentTime = getCurrentTime()
        documentData.updateValue("\(currentTime)", forKey: "time")
        documentData.updateValue(scan.pageCount, forKey: "numOfPages")
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        let name = alertView.addTextField("")
        alertView.addButton("Save") {
            if (name.text == "") {
                documentName = "\(currentTime)"
                for pageIndex in 0..<scan.pageCount {
                    documentData.updateValue("gs://usscanner.appspot.com/documents/\((self.currentUser?.email)!)/\(currentTime)-\(pageIndex)", forKey: "\(currentTime)-\(pageIndex)")
                }
            }
            else {
                documentName = "\(name.text!)"
                for pageIndex in 0..<scan.pageCount {
                    documentData.updateValue("gs://usscanner.appspot.com/documents/\((self.currentUser?.email)!)/\(name.text!)-\(pageIndex)", forKey: "\(name.text!)-\(pageIndex)")
                }
            }
            
            let dispatchGroup = DispatchGroup()

            let hud = JGProgressHUD(style:  .dark)
            hud.textLabel.text = "Uploading..."
            hud.show(in: self.view)
            
            for pageIndex in 0..<scan.pageCount {
                dispatchGroup.enter()
                self.db.collection("documents").document((self.currentUser?.email)!).updateData(["\(documentName!)":documentData]) { (error) in
                    if error != nil {
                        // Show error alert
                        SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                    }
                    else {
                        // Upload photo
                        let storageRef = self.storage.reference().child("documents/\((self.currentUser?.email)!)/\(documentName!)-\(pageIndex)")
                        
                        let imageData = scan.imageOfPage(at: pageIndex).jpegData(compressionQuality: 0.8)
                        
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/jpeg"
                        
                        storageRef.putData(imageData!, metadata: metaData) { (metaData, error) in
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                hud.dismiss()
                SCLAlertView().showSuccess("Success", subTitle: "All your new documents have been saved!")
                let tabbarViewControllers = self.tabBarController?.viewControllers
                let vc = tabbarViewControllers![1] as! StoreDataViewController
                if (vc.isInitVC) {
                    self.listener.didUploadNewDocument()
                }
            }
        }
        alertView.addButton("Cancel") {
            print("Cancel")
        }
        alertView.showInfo("Save your document?", subTitle: "Enter your document's name:")

        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ProfileViewController : DialogConfirmDelegate {
    func accept() {
        for item in self.navigationController!.viewControllers {
            if item is ViewController {
                ManageCacheObject.clearData()
                navigationController?.popToViewController(item, animated: false)
                return
            }
        }
    }
    
    func deny() {
        
    }
}
