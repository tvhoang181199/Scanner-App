//
//  StoreDataViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 02/12/2020.
//

import UIKit
import JGProgressHUD
import SCLAlertView
import Firebase
import FirebaseAuth
import FirebaseStorage

struct DocumentData {
    var title:String? = ""
    var numOfPages: Int? = 0
    var time: String? = ""
    var images:[UIImage?] = []
}

class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var documentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numOfPagesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var splitline: UIView!
    
    var images: [UIImage?] = []
    
    func setDocument(_ document:DocumentData) {
        documentImageView.image = document.images[0]
        titleLabel.text = document.title!
        numOfPagesLabel.text = "Total Pages: \(document.numOfPages!)"
        timeLabel.text = "Time: \(document.time!)"
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    
    func incrementHUD(_ hud: JGProgressHUD, progress previousProgress: Int) {
            let progress = previousProgress + 1
            hud.progress = Float(progress)/100.0
            hud.detailTextLabel.text = "\(progress)% Complete"
            
            if progress == 100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    UIView.animate(withDuration: 0.1, animations: {
                        hud.textLabel.text = "Success"
                        hud.detailTextLabel.text = nil
                        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    })
                    hud.dismiss(afterDelay: 1.0)
                }
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20)) {
                    self.incrementHUD(hud, progress: progress)
                }
            }
        }
    
    @IBAction func saveImageTapped(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Yes") {
            for i in 0..<self.images.count {
                UIImageWriteToSavedPhotosAlbum(self.images[i]!, self, nil, nil)
            }
            let hud = JGProgressHUD(style:  .dark)
            hud.vibrancyEnabled = true
            if arc4random_uniform(2) == 0 {
                hud.indicatorView = JGProgressHUDPieIndicatorView()
            }
            else {
                hud.indicatorView = JGProgressHUDRingIndicatorView()
            }
            hud.detailTextLabel.text = "0% Complete"
            hud.textLabel.text = "Saving"
            hud.show(in: self.superview!.superview!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                self.incrementHUD(hud, progress: 0)
            }
        }
        alertView.addButton("No") {
        }
        
        alertView.showInfo("Save Document", subTitle: "Do you want to save all pages of your documents as photos?")
    }
}

class StoreDataViewController : UIViewController, NavigationControllerCustomDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var documentsTableView: UITableView!
    
    var documentsList: [String:DocumentData] = [:]
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let currentUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentsTableView.delegate = self
        documentsTableView.dataSource = self
        
//        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "DATA")
        navigationControllerCustom.navigationBar.isHidden = true
        
        // Fetch data
        fetchData()
    }
    
    func presentData() {
        documentsTableView.reloadData()
    }

    // MARK: - TableView Protocols
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath) as! DocumentCell
        cell.setDocument(Array(documentsList.values)[indexPath.row])
        cell.images = Array(documentsList.values)[indexPath.row].images
        if (indexPath.row == documentsList.count-1) {
            cell.splitline.isHidden = true
        }
        else {
            cell.splitline.isHidden = false
        }
        return cell
    }
    // MARK: - fetchData
    func fetchData() {
        documentsList.removeAll()
        let hud = JGProgressHUD(style:  .dark)
        hud.show(in: self.view)
        
        db.collection("documents").document((currentUser?.email)!).getDocument { (snapshot, error) in
            if let error = error {
                hud.dismiss()
                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
            }
            else {
                let dispatchGroup = DispatchGroup()
                for key in (snapshot?.data() as Dictionary).keys {
                    self.documentsList.updateValue(DocumentData(), forKey: key)
                    self.documentsList[key]?.title = "\(key)"
                    self.documentsList[key]?.time = ((snapshot?.data()![key] as! Dictionary<String, Any>)["time"]! as! String)
                    self.documentsList[key]?.numOfPages = ((snapshot?.data()![key] as! Dictionary<String, Any>)["numOfPages"]! as! Int)
                    for i in 0..<(self.documentsList[key]?.numOfPages!)! {
                        dispatchGroup.enter()
                        let imageRef = Storage.storage().reference(forURL: ((snapshot?.data()![key] as! Dictionary<String, Any>)["\(key)-\(i)"]! as! String))
                        imageRef.getData(maxSize: 1*4096*4096) { (data, error) in
                            if let error = error {
                                hud.dismiss()
                                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                            }
                            else {
                                self.documentsList[key]?.images.append(UIImage(data: data!))
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    hud.dismiss()
                    self.presentData()
                }
            }
        }
    }
    
}
