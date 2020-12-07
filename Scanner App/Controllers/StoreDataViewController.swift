//
//  StoreDataViewController.swift
//  Scanner App
//
//  Created by Gia Huy on 02/12/2020.
//

import UIKit
import PDFKit
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

protocol ShareDocmentProtocol {
    func shareDocumentAsText(_ data: DocumentData)
    func shareDocumentAsPDF(_ data: DocumentData)
}

class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var documentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numOfPagesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var splitline: UIView!
    
    var documentData = DocumentData()
    var delegate: ShareDocmentProtocol!
    
    func setDocument(_ document:DocumentData) {
        documentData = document
        documentImageView.image = document.images[0]
        titleLabel.text = document.title!
        numOfPagesLabel.text = "Total Pages: \(document.numOfPages!)"
        timeLabel.text = "Time: \(document.time!)"
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("PDF") {
            self.delegate.shareDocumentAsPDF(self.documentData)
        }
        alertView.addButton("TEXT/JPG") {
            self.delegate.shareDocumentAsText(self.documentData)
        }
        alertView.addButton("Cancel") {
        }
        
        alertView.showWarning("Share as", subTitle: "")
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
            for i in 0..<self.documentData.images.count {
                UIImageWriteToSavedPhotosAlbum(self.documentData.images[i]!, self, nil, nil)
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
            hud.textLabel.text = "Saving..."
            hud.show(in: self.superview!.superview!.superview!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                self.incrementHUD(hud, progress: 0)
            }
        }
        alertView.addButton("No") {
        }
        
        alertView.showInfo("Save Document", subTitle: "Do you want to save all pages of your documents as photos?")
    }
}

class StoreDataViewController : UIViewController, NavigationControllerCustomDelegate, UITableViewDelegate, UITableViewDataSource, UploadDocumentProtocol, ShareDocmentProtocol {
    
    @IBOutlet weak var documentsTableView: UITableView!
    
    var documentsData: [String:DocumentData] = [:]
    var documentsListSorted: [DocumentData] = []
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let currentUser = Auth.auth().currentUser
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentsTableView.delegate = self
        documentsTableView.dataSource = self
        
        let tabbarViewControllers = self.tabBarController?.viewControllers
        let vc = tabbarViewControllers![0] as! ProfileViewController
        vc.listener = self
        
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self, action: #selector(refetchData), for: .valueChanged)
        documentsTableView.addSubview(refreshControl)
        
        // fetchData
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Custom navigation bar
        let navigationControllerCustom : NavigationControllerCustom = self.navigationController as! NavigationControllerCustom
        navigationControllerCustom.setUpNavigationBar(self, hideBackButton:true, hideFilterButton:true, title: "DATA")
        navigationControllerCustom.navigationBar.isHidden = true
    }

    
    @objc private func refetchData() {
        documentsData.removeAll()
        documentsListSorted.removeAll()
        db.collection("documents").document((currentUser?.email)!).getDocument { (snapshot, error) in
            if let error = error {
                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
            }
            else {
                let dispatchGroup = DispatchGroup()
                for key in (snapshot?.data() as Dictionary).keys {
                    self.documentsData.updateValue(DocumentData(title: "\(key)",
                                                                numOfPages: ((snapshot?.data()![key] as! Dictionary<String, Any>)["numOfPages"]! as! Int),
                                                                time: ((snapshot?.data()![key] as! Dictionary<String, Any>)["time"]! as! String),
                                                                images: [UIImage?](repeating: UIImage(), count: ((snapshot?.data()![key] as! Dictionary<String, Any>)["numOfPages"]! as! Int))),
                                                   forKey: key)
                    for i in 0..<(self.documentsData[key]?.numOfPages!)! {
                        dispatchGroup.enter()
                        let imageRef = Storage.storage().reference(forURL: ((snapshot?.data()![key] as! Dictionary<String, Any>)["\(key)-\(i)"]! as! String))
                        imageRef.getData(maxSize: 1*4096*4096) { (data, error) in
                            if let error = error {
                                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                            }
                            else {
                                self.documentsData[key]?.images[i] = UIImage(data: data!)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.documentsListSorted = Array(self.documentsData.values).sorted { ($0 as DocumentData).title!.lowercased() < ($1 as DocumentData).title!.lowercased() }
                    self.documentsTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func presentData() {
        documentsTableView.reloadData()
    }

    // MARK: - TableView Protocols
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (!documentsListSorted.isEmpty) ? documentsListSorted.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath) as! DocumentCell
        if (!documentsData.isEmpty && !documentsListSorted.isEmpty) {
            cell.delegate = self
            cell.setDocument(documentsListSorted[indexPath.row])
            if (indexPath.row == documentsData.count-1) {
                cell.splitline.isHidden = true
            }
            else {
                cell.splitline.isHidden = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Yes") {
                let hud = JGProgressHUD(style:  .dark)
                hud.textLabel.text = "Deleting..."
                hud.show(in: self.view)
                self.db.collection("documents").document((self.currentUser?.email)!).updateData(["\(self.documentsListSorted[indexPath.row].title!)":FieldValue.delete()]) { (error) in
                    if let error = error {
                        hud.dismiss()
                        SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                    }
                    else {
                        let dispatchGroup = DispatchGroup()
                        for i in 0..<self.documentsListSorted[indexPath.row].numOfPages! {
                            dispatchGroup.enter()
                            let imageRef = Storage.storage().reference(forURL: "gs://usscanner.appspot.com/documents/\((self.currentUser?.email)!)/\(self.documentsListSorted[indexPath.row].title!)-\(i)")
                            imageRef.delete { (error) in
                                if let error = error {
                                    SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                                    return
                                }
                                else {
                                    dispatchGroup.leave()
                                }
                            }
                        }
                        dispatchGroup.notify(queue: .main) {
                            hud.dismiss()
                            self.documentsData.removeValue(forKey: "\(self.documentsListSorted[indexPath.row].title!)")
                            self.documentsListSorted.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
            alertView.addButton("No") {
            }
            
            alertView.showWarning("Delete \"\(documentsListSorted[indexPath.row].title!)\"", subTitle: "Are you sure?")
        }
    }
    
    // MARK: - ShareDocmentProtocol
    func shareDocumentAsText(_ data: DocumentData) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "shareDocumentViewController") as! ShareDocumentViewController
        vc.modalPresentationStyle = .fullScreen
        vc.documentData = data
        self.present(vc, animated: true)
    }
    
    func shareDocumentAsPDF(_ data: DocumentData) {
        let pdfDocument = PDFDocument()
        for i in 0..<data.images.count {
            let pdfPage = PDFPage(image: data.images[i]!)
            pdfDocument.insert(pdfPage!, at: i)
        }
        
        let pdfData = pdfDocument.dataRepresentation()
        
        let documentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let dirPath = documentDirectory.appendingPathComponent("USScanner")
        do {
            try FileManager.default.createDirectory(atPath: dirPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
        }
        
        let docURL = dirPath?.appendingPathComponent("\(data.title!).pdf")
        do {
            try pdfData?.write(to: docURL!)
        }
        catch let error as NSError {
            print("Unable to write data \(error.debugDescription)")
        }
        
        let ac = UIActivityViewController(activityItems: [URL(string: docURL!.absoluteString)!], applicationActivities: nil)
        self.present(ac, animated: true)
    }
    
    // MARK: - UploadDocumentProtocol
    func didUploadNewDocument() {
        fetchData()
    }
    
    // MARK: - fetchData
    func fetchData() {
        documentsData.removeAll()
        documentsListSorted.removeAll()
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
                    self.documentsData.updateValue(DocumentData(title: "\(key)",
                                                                numOfPages: ((snapshot?.data()![key] as! Dictionary<String, Any>)["numOfPages"]! as! Int),
                                                                time: ((snapshot?.data()![key] as! Dictionary<String, Any>)["time"]! as! String),
                                                                images: [UIImage?](repeating: UIImage(), count: ((snapshot?.data()![key] as! Dictionary<String, Any>)["numOfPages"]! as! Int))),
                                                   forKey: key)
                    for i in 0..<(self.documentsData[key]?.numOfPages!)! {
                        dispatchGroup.enter()
                        let imageRef = Storage.storage().reference(forURL: ((snapshot?.data()![key] as! Dictionary<String, Any>)["\(key)-\(i)"]! as! String))
                        imageRef.getData(maxSize: 1*4096*4096) { (data, error) in
                            if let error = error {
                                hud.dismiss()
                                SCLAlertView().showError("Error", subTitle: error.localizedDescription)
                                return
                            }
                            else {
                                self.documentsData[key]?.images[i] = UIImage(data: data!)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.documentsListSorted = Array(self.documentsData.values).sorted { ($0 as DocumentData).title!.lowercased() < ($1 as DocumentData).title!.lowercased() }
                    hud.dismiss()
                    self.presentData()
                }
            }
        }
    }
    
}

extension UIApplication
{

    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            let top = topViewController(nav.visibleViewController)
            return top
        }

        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                let top = topViewController(selected)
                return top
            }
        }

        if let presented = base?.presentedViewController
        {
            let top = topViewController(presented)
            return top
        }
        return base
    }
}
