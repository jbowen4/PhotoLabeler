//
//  PhotoHelper.swift
//  Picture Labeler
//
//  Created by Joshua Bowen on 2/8/20.
//  Copyright © 2020 Joshua Bowen. All rights reserved.
//

import Foundation
import UIKit
import Photos
import BSImagePicker

class PhotoHelper {
    
    func choosePhotos(vc: UIViewController) -> [PHAsset] {
        var selectedAssets = [PHAsset]()
    
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a Source", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = (vc as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            imagePickerController.sourceType = .camera
            vc.present(imagePickerController, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (UIAlertAction) in
            let imagePicker = ImagePickerController()

            vc.presentImagePicker(imagePicker, animated: true, select: { (asset) in
                // Select
            }, deselect: { (asset) in
                // Deselect
            }, cancel: { (assets) in
                // Cancel
            }, finish: { (assets) in
                for i in 0..<assets.count {
                    selectedAssets.append(assets[i])
                }
                self.convertAssetToImages(vc: vc, assets: selectedAssets)

                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    let vc = vc.storyboard?.instantiateViewController(identifier: "imageSave") as! ImageSaveController
                    vc.modalPresentationStyle = .overFullScreen
//                    vc.modalTransitionStyle = .crossDissolve
                    vc.present(vc, animated: true, completion: nil)
                })
            }, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
        
        return selectedAssets
    }
    
    func convertAssetToImages(vc: UIViewController, assets: [PHAsset]) -> [UIImage] {
        var photoArray = [UIImage]()
        
         if assets.count != 0{
             for i in 0..<assets.count{
                 let manager = PHImageManager.default()
                 let option = PHImageRequestOptions()
                 var thumbnail = UIImage()
                 option.isSynchronous = true
                 manager.requestImage(for: assets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                     thumbnail = result!
                     
                 })
                 let data = thumbnail.jpegData(compressionQuality: 0.7)
                 let newImage = UIImage(data: data!)
                 photoArray.append(newImage! as UIImage)
             }
         }
        
        return photoArray
     }
}
