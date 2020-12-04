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

class ProfileViewController : UIViewController, NavigationControllerCustomDelegate, VNDocumentCameraViewControllerDelegate {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("asdadas - " + getCurrentTime())
        print((currentUser?.email)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "PROFILE")
        navigationControllerCustom.navigationBar.isHidden = true
    
    }
    
    @IBAction func scanButtonTapped(_ sender: Any) {
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = self
        self.present(scannerVC, animated: true, completion: nil)
    }
    
    func getCurrentTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: Date())
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let dispatchGroup = DispatchGroup()

        let currentTime = getCurrentTime()
        
        let hud = JGProgressHUD(style:  .dark)
        hud.textLabel.text = "Uploading..."
        hud.show(in: self.view)
        
        for pageIndex in 0..<scan.pageCount {
            dispatchGroup.enter()
            self.db.collection("documents").document((currentUser?.email)!).updateData(["\(currentTime) - \(pageIndex)":"gs://usscanner.appspot.com/\((currentUser?.email)!)/\(currentTime) - \(pageIndex)"]) { (error) in
                if error != nil {
                    // Show error alert
                    SCLAlertView().showError("Error", subTitle: error!.localizedDescription)
                }
                else {
                    // Upload photo
                    let storageRef = self.storage.reference().child("documents/\((self.currentUser?.email)!)/\(currentTime) - \(pageIndex)")
                    
                    let imageData = scan.imageOfPage(at: pageIndex).jpegData(compressionQuality: 1)
                    
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
        }

        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
