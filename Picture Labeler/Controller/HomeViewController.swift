//
//  ViewController.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 1/8/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import UIKit

import Photos
import BSImagePicker
import CoreData

typealias ImageArray = [UIImage]
typealias ImageArrayRepresentation = Data

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var photoSearchBar: UISearchBar!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    var selectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    var cdArray: ImageArrayRepresentation?
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var groups = [ImageGroup]()
    
//    let imageHandler = ImageDAO(container: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        let request : NSFetchRequest<ImageGroup> = ImageGroup.fetchRequest()
        do{groups = (try context?.fetch(request))!}
        catch {}
        
        photoCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        
        let imgArray = groups[indexPath.row].imageArray?.imageArray()
        
        var image: UIImage = (imgArray!.count > 0 ? imgArray![0] : UIImage(named: "homework"))!
        
        cell.photoImageView.image = image
        cell.photoDescription.text = groups[indexPath.row].name
        
        formatCell(cell: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupVC = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "groupVC") as? GroupViewController)!
        groupVC.imageArray = (groups[indexPath.row].imageArray?.imageArray())!
        groupVC.navTitle = groups[indexPath.row].name
        groupVC.object = groups[indexPath.row]
        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    @IBAction func chooseImages(_ sender: Any) {
        
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

                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    let vc = self.storyboard?.instantiateViewController(identifier: "imageSave") as! ImageSaveController
                    vc.modalPresentationStyle = .overFullScreen
//                    vc.modalTransitionStyle = .crossDissolve
                    vc.imageArray = self.photoArray
                    vc.cdArray = self.cdArray
                    self.present(vc, animated: true, completion: nil)
                })
            }, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
                
                cdArray = photoArray.coreDataRepresentation()
            }
        }
    }
    
}

extension HomeViewController {
    func formatCell(cell: UICollectionViewCell) {
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
    }
}

extension HomeViewController {
    func makeNewCollection(images: ImageArrayRepresentation) {
        
    }
}

extension Array where Element: UIImage {
    // Given an array of UIImages return a Data representation of the array suitable for storing in core data as binary data that allows external storage
    func coreDataRepresentation() -> ImageArrayRepresentation? {
        let CDataArray = NSMutableArray()

        for img in self {
            guard let imageRepresentation = img.pngData() else {
                print("Unable to represent image as PNG")
                return nil
            }
            let data : NSData = NSData(data: imageRepresentation)
            CDataArray.add(data)
        }

        do {
            return try NSKeyedArchiver.archivedData(withRootObject: CDataArray, requiringSecureCoding: false)
        } catch {
            print(error)
            return nil
        }
        
    }
}

extension ImageArrayRepresentation {
    // Given a Data representation of an array of UIImages return the array
    func imageArray() -> ImageArray? {
        if let mySavedData = NSKeyedUnarchiver.unarchiveObject(with: self) as? NSArray {
            // TODO: Use regular map and return nil if something can't be turned into a UIImage
            let imgArray = mySavedData.flatMap({
                return UIImage(data: $0 as! Data)
            })
            return imgArray
        }
        else {
            print("Unable to convert data to ImageArray")
            return nil
        }
    }
}
