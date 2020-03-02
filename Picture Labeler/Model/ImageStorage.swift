////
////  ImageStorage.swift
////  Picture Labeler
////
////  Created by Joshua Bowen on 2/15/20.
////  Copyright © 2020 Joshua Bowen. All rights reserved.
////
//
//import Foundation
//import UIKit.UIImage
//import CoreData
//
//class ImageDAO {
//    private let container: NSPersistentContainer
//
//    init(container: NSPersistentContainer) {
//        self.container = container
//    }
//
//    func makeInternallyStoredImage(_ bitmap: UIImage) -> Photo {
//        let image = insert(Photo.self, into: container.viewContext)
//        image.blob = bitmap.toData() as Data?
//        saveContext()
//        return image
//    }
//
//    func internallyStoredImage(by id: NSManagedObjectID) -> Photo {
//        return container.viewContext.object(with: id) as! Photo
//    }
//
//    private func saveContext() {
//        try! container.viewContext.save()
//    }
//
//    private func insert<T>(_ type: T.Type, into context: NSManagedObjectContext) -> T {
//        return NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
//    }
//}
//
//
//extension UIImage {
//
//    func toData() -> Data? {
//        return pngData()
//    }
//
//    var sizeInBytes: Int {
//        if let data = toData() {
//            return data.count
//        } else {
//            return 0
//        }
//    }
//
//    var sizeInMB: Double {
//        return Double(sizeInBytes) / 1_000_000
//    }
//}
