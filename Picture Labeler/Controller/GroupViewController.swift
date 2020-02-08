//
//  GroupViewController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/5/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupCollectionView.delegate = self
        groupCollectionView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = groupCollectionView.dequeueReusableCell(withReuseIdentifier: "photoGroupCell", for: indexPath) as! GroupViewCell

        cell.photoImageView.image = UIImage(named: "homework")
        
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.masksToBounds = true

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let galleryVC = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "galleryVC") as? GalleryViewController)!
        self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    
    @IBAction func addPhotos(_ sender: Any) {
    }
    
    @IBAction func sendPhotos(_ sender: Any) {
    }
    
    @IBAction func selectPhotos(_ sender: Any) {
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
    }
    
    
}
