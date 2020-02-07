//
//  ViewController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 1/8/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var photoSearchBar: UISearchBar!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        
        cell.photoImageView.image = UIImage(named: "homework")
        cell.photoDescription.text = "Web"
        
        cell.contentView.layer.cornerRadius = 15
        cell.layer.cornerRadius = 15
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 0.5
        cell.layer.shadowOpacity = 1
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupVC = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "groupVC") as? GroupViewController)!
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
}

