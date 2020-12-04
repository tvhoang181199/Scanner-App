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
    var title:String?
    var image:UIImage?
}

class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var documentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func setDocument(_ image: UIImage, _ title: String) {
        documentImageView.image = image
        titleLabel.text = title
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveImageTapped(_ sender: Any) {
    }
}

class StoreDataViewController : UIViewController, NavigationControllerCustomDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var documentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentsTableView.delegate = self
        documentsTableView.dataSource = self
        
        documentsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "DATA")
        navigationControllerCustom.navigationBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath) as! DocumentCell
        
        cell.titleLabel.text = "Text - Text"
        
        return cell
    }
    
}
