//
//  GalleryViewController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/7/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
   
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self

        imageScrollView.delegate = self
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
