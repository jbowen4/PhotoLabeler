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

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, GroupDelegate {
    @IBOutlet weak var photoSearchBar: UISearchBar!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    enum Mode {
        case view
        case delete
    }
    
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                doneButton.isEnabled = false
                doneButton.title = nil
                print("view")
            case .delete:
                doneButton.isEnabled = true
                doneButton.title = "Done"
                print("delete")
            }
        }
    }
    
    var selectedAssets = [PHAsset]()
    var photoArray = [UIImage]()
    var cdArray: ImageArrayRepresentation?
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var groups = [ImageGroup]()
    var realData = [ImageGroup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        doneButton.title = nil
        
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2
                
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoSearchBar.delegate = self
        
        let request : NSFetchRequest<ImageGroup> = ImageGroup.fetchRequest()
        do{groups = (try context?.fetch(request))!}
        catch {}
        
        realData = groups
        
        let width = (view.frame.size.width - 25) / 2
        let layout = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        
        var image: UIImage!
        
        if let imgArray = groups[indexPath.row].imageArray?.imageArray() {
            image = (imgArray.count > 0 ? imgArray[0] : UIImage(named: "homework"))!
        } else {
            image = UIImage(named: "homework")
        }
        
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        cell.addGestureRecognizer(longPressRecognizer)
        
        cell.photoImageView.image = image
        cell.photoDescription.text = groups[indexPath.row].name
        
        formatCell(cell: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mMode {
        case .view:
            let groupVC = (UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "groupVC") as? GroupViewController)!
            groupVC.imageArray = (groups[indexPath.row].imageArray?.imageArray())!
            groupVC.navTitle = groups[indexPath.row].name
            groupVC.object = groups[indexPath.row]
            self.navigationController?.pushViewController(groupVC, animated: true)
        case.delete:
            editGroup(index: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
                self.selectedAssets = []
                for i in 0..<assets.count {
                    self.selectedAssets.append(assets[i])
                }
                self.convertAssetToImages()

                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    let vc = self.storyboard?.instantiateViewController(identifier: "imageSave") as! ImageSaveController
                    vc.modalPresentationStyle = .overFullScreen
                    vc.imageArray = self.photoArray
                    vc.cdArray = self.cdArray
                    vc.delegate = self
                    self.present(vc, animated: true, completion: nil)
                })
            }, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.photoArray = []
        self.cdArray = nil
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        photoArray = [image]
        
        picker.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let vc = self.storyboard?.instantiateViewController(identifier: "imageSave") as! ImageSaveController
            vc.modalPresentationStyle = .overFullScreen
            vc.imageArray = self.photoArray
            vc.cdArray = self.photoArray.coreDataRepresentation()
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func convertAssetToImages() -> Void {
        self.photoArray = []
        self.cdArray = nil
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.groups.removeAll()
            
        for item in self.realData {
            if (item.name!.lowercased().contains(photoSearchBar.searchTextField.text!.lowercased())) {
                self.groups.append(item)
            }
        }
                            
        if (photoSearchBar.text!.isEmpty) {
            self.groups = self.realData
        }
        
        self.photoCollectionView.reloadData()
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        mMode = .delete
    }
    
    @IBAction func doneDelete(_ sender: Any) {
        mMode = .view
    }
    
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
    
    func editGroup(index: IndexPath) {
        let editAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.edit(index: index)
        }
        let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.delete(index: index)
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                  style: .cancel) { (action) in
        }
             
        let alert = UIAlertController(title: "Edit this image(s)",
                    message: "",
                    preferredStyle: .actionSheet)
        alert.addAction(editAction)
        alert.addAction(destroyAction)
        alert.addAction(cancelAction)
             
        self.present(alert, animated: true)
    }
    
    func edit(index: IndexPath) {
        let item = groups[index.row]

        var nameField = UITextField()
        
        let menu = UIAlertController(title: "Edit Name", message: "Current Name: \(item.name ?? "")", preferredStyle: .alert)
        
        menu.addTextField { (menuTextField) in
            menuTextField.placeholder = "Name"
            menuTextField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
            
            nameField = menuTextField
        }
        let save = UIAlertAction(title: "Save", style: .default) { (action) in
            item.name = nameField.text!
            
            do {
                try self.self.context?.save()
            } catch {}
            
            self.photoCollectionView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
            return
        }
        menu.addAction(cancel)
        menu.addAction(save)
        menu.actions[1].isEnabled = false
        
        self.present(menu, animated: true, completion: nil)
    }
    
    func delete(index: IndexPath) {
        let alert = UIAlertController(title: "Delete \(self.groups[index.row].name!)?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
            do {
                self.context?.delete(self.groups[index.row])
                try self.context?.save()
            } catch {}
            self.groups.remove(at: index.row)
            self.realData = self.groups
            self.photoCollectionView.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func textChanged(_ sender: Any) {
           let tf = sender as! UITextField
           var resp : UIResponder! = tf
           while !(resp is UIAlertController) { resp = resp.next }
           let alert = resp as! UIAlertController
           if alert.textFields?.first?.text != "" && alert.textFields?.last?.text != "" {
               alert.actions[1].isEnabled = true
           } else {
               alert.actions[1].isEnabled = false
           }
       }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            self.photoSearchBar.endEditing(true)
            searchBar.resignFirstResponder()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        photoSearchBar.endEditing(true)
        photoSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.photoSearchBar.endEditing(true)
        photoSearchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.photoSearchBar.endEditing(true)
        photoSearchBar.resignFirstResponder()
    }
    
    func updateGroups() {
        let request : NSFetchRequest<ImageGroup> = ImageGroup.fetchRequest()
        do{groups = (try context?.fetch(request))!}
        catch {}
        
        realData = groups
        
        self.photoCollectionView.reloadData()
    }
    
    
}

extension Array where Element: UIImage {
    // Given an array of UIImages return a Data representation of the array suitable for storing in core data as binary data that allows external storage
    func coreDataRepresentation() -> ImageArrayRepresentation? {
        let CDataArray = NSMutableArray()

        for img in self {
            guard let imageRepresentation = img.jpegData(compressionQuality: 1.0) else {
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
