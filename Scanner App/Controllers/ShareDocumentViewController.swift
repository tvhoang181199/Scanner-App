//
//  ShareDocumentViewController.swift
//  Scanner App
//
//  Created by Trịnh Vũ Hoàng on 06/12/2020.
//

import UIKit
import JGProgressHUD
import TesseractOCR

class ShareDocumentViewController: UIViewController, UIScrollViewDelegate, G8TesseractDelegate {
    
    var documentData = DocumentData()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var textView: UITextView!

    let tesseract = G8Tesseract(language: "eng")
    let hud = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        tesseract!.delegate = self
        
        tesseract!.image = documentData.images[0]?.g8_blackAndWhite()
        
        hud.textLabel.text = "Processing..."
        hud.show(in: self.view)
        DispatchQueue.global().async {
            self.tesseract!.recognize()
            DispatchQueue.main.async {
                self.hud.dismiss()
                self.textView.text = self.tesseract!.recognizedText
            }
        }
        setupUIComponents()
    }
    
    func setupUIComponents() {
        self.view.layoutIfNeeded()
        var frame = CGRect(x:0, y:0, width: 0, height: 0)
        frame.size = scrollView.bounds.size
        
        title = documentData.title
        pageControl.numberOfPages = documentData.images.count
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceVertical = false
        for i in 0..<documentData.images.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(i)
            
            let imageView = UIImageView(frame: frame)
            imageView.image = documentData.images[i]
            imageView.contentMode = .scaleAspectFit
            self.scrollView.addSubview(imageView)
        }
        scrollView.contentSize = CGSize(width: (scrollView.frame.size.width * CGFloat(documentData.images.count)), height: scrollView.frame.size.height)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = pageIndex
        
        tesseract!.image = documentData.images[pageIndex]?.g8_blackAndWhite()
        hud.textLabel.text = "Processing..."
        hud.show(in: self.view)
        DispatchQueue.global().async {
            self.tesseract!.recognize()
            DispatchQueue.main.async {
                self.hud.dismiss()
                self.textView.text = self.tesseract!.recognizedText
            }
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {

    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
