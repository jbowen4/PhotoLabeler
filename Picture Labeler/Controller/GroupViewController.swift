//
//  GroupViewController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/5/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker
import SwiftPhotoGallery

class GroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var testArray = [UIImage(named: "homework"), UIImage(named: "homework"), UIImage(named: "homework"), UIImage(named: "homework"), UIImage(named: "homework")]
    
    var selectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    
    var selectOn: Bool = false
    
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                for (key, value) in dictionarySelectedIndexPath {
                    if value {
                        groupCollectionView.deselectItem(at: key, animated: true)
                    }
                }
                selectButton.title = "Select"
                sendButton.isEnabled = false
                deleteButton.isEnabled = false
                groupCollectionView.allowsMultipleSelection = false
            case .select:
                selectButton.title = "Cancel"
                sendButton.isEnabled = true
                deleteButton.isEnabled = true
                groupCollectionView.allowsMultipleSelection = true
            }
        }
    }
    
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupCollectionView.delegate = self
        groupCollectionView.dataSource = self
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = groupCollectionView.dequeueReusableCell(withReuseIdentifier: "photoGroupCell", for: indexPath) as! GroupViewCell

        cell.photoImageView.image = testArray[indexPath.row]
        
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.masksToBounds = true

        return cell
    }

    func collectionView(_ collectionView:  UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mMode {
            case .view:
                groupCollectionView.deselectItem(at: indexPath, animated: true)
                let galleryVC = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "galleryVC") as? GalleryViewController)!
                self.navigationController?.pushViewController(galleryVC, animated: true)
            case .select:
                dictionarySelectedIndexPath[indexPath] = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mMode == .select {
            dictionarySelectedIndexPath[indexPath] = false
        }
    }
    
    @IBAction func addPhotos(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a Source", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (UIAlertAction) in
            let imagePicker = ImagePickerController()

            self.presentImagePicker(imagePicker, animated: true, select: { (asset) in
                // Select
            }, deselect: { (asset) in
                // Deselect
            }, cancel: { (assets) in
                // Cancel
            }, finish: { (assets) in
                for i in 0..<assets.count {
                    self.selectedAssets.append(assets[i])
                }
                self.convertAssetToImages()
            }, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func sendPhotos(_ sender: Any) {
        mMode = mMode == .view ? .select : .view
    }
    
    @IBAction func selectPhotos(_ sender: Any) {
        mMode = mMode == .view ? .select : .view
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
        mMode = mMode == .view ? .select : .view
        
        var deleteNeededIndexPaths: [IndexPath] = []
        for (key, value) in dictionarySelectedIndexPath {
            if value {
                deleteNeededIndexPaths.append(key)
            }
        }
        
        for i in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
            testArray.remove(at: i.item)
        }
        
        groupCollectionView.deleteItems(at: deleteNeededIndexPaths)
        dictionarySelectedIndexPath.removeAll()
        groupCollectionView.reloadData()
    }
    
    func convertAssetToImages() -> Void {
        if selectedAssets.count != 0{
            for i in 0..<selectedAssets.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                    
                })
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                self.photoArray.append(newImage! as UIImage)
            }
        }
    }
    
}
