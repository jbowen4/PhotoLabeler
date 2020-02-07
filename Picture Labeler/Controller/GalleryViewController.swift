//
//  GalleryViewController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/7/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 3
    }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "singleCell", for: indexPath) as! GroupViewCell

        cell.photoImageView.image = UIImage(named: "homework")

        return cell
    }
    
    
    

}
