//
//  ImageSaveController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/7/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit
import CoreData

protocol GroupDelegate {
    func updateGroups()
}

class ImageSaveController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var imagePageControl: UIPageControl!
    @IBOutlet weak var popupView: UIView!
    
    var imageArray = [UIImage]()
    var cdArray: ImageArrayRepresentation?
    
    var homeVC: HomeViewController?
    
    var delegate : GroupDelegate? = nil
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 15
        
        imageScrollView.delegate = self
                
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
        save(groupNameField.text!, cdArray!)
        
        dismiss(animated: true, completion: nil)
    }
    
    func save(_ itemName: String, _ itemImages: ImageArrayRepresentation) {
        let entity = NSEntityDescription.entity(forEntityName: "ImageGroup", in: context!)!
        let item = NSManagedObject(entity: entity, insertInto: context)
        item.setValue(itemName, forKey: "name")
        item.setValue(cdArray, forKey: "imageArray")
        
        do {
            try context!.save()
        } catch let err as NSError {
            print("Failed to save an item", err)
        }
        
        self.delegate?.updateGroups()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        groupNameField.resignFirstResponder()
    }
    

}
