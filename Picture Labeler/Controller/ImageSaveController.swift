//
//  ImageSaveController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/7/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit

class ImageSaveController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var imagePageControl: UIPageControl!
    @IBOutlet weak var popupView: UIView!
    
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 15
        
        imageScrollView.delegate = self
        
        imageArray = [UIImage(named: "homework")!, UIImage(named: "homework")!]
        
        if imageArray.count > 1 {
            imagePageControl.isHidden = false
            imagePageControl.numberOfPages = imageArray.count
        }
        
        for i in 0..<imageArray.count {
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            imageView.contentMode = .scaleAspectFit
            let xpos = self.imageScrollView.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xpos, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i + 1)
            imageScrollView.addSubview(imageView)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        imagePageControl.currentPage = Int(page)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
    }
    

}
