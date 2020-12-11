//
//  PreviewDocumentViewController.swift
//  Scanner App
//
//  Created by Trịnh Vũ Hoàng on 11/12/2020.
//

import UIKit

class PreviewDocumentViewController: UIViewController, UIScrollViewDelegate {
    
    var documentData = DocumentData()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        setUpUIElements()
        
    }
    
    func setUpUIElements() {
        self.view.layoutIfNeeded()
        var frame = CGRect(x:0, y:0, width: 0, height: 0)
        frame.size = scrollView.bounds.size
        
        titleLabel.text = documentData.title
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
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
