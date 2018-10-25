//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/16.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {

    var images = [UIImage]()
    var imageARAndURLs = [[String: Any]]()   // AR is short for Aspect Ratio
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageARAndURLs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageView.image = (imageARAndURLs[indexPath.item]["image"] as! UIImage)
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 250
        let height: CGFloat = (imageARAndURLs[indexPath.item]["aspectRatio"] as! CGFloat) * width
        return CGSize(width: width, height: height)
    }
    
    
    
    // MARK: UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let draggedImage = (collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: draggedImage))
            return [dragItem]
        } else {
            return []
        }
    }
    
    
    // MARK: UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if isDragFromWithin(of: session) {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: URL.self)
        }
    }
    // go back and check .move and .copy after implementing the move drop
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if isDragFromWithin(of: session) {
            return UICollectionViewDropProposal(operation: destinationIndexPath != nil ? .move : .cancel, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    private func isDragFromWithin(of session: UIDropSession) -> Bool {
        return (session.localDragSession?.localContext as? UICollectionView) == collectionView
    }
    
    // to prevent app from crashing of 'attempt to begin reordering on collection view while reordering is already in progress'
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        collectionView.endInteractiveMovement()
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        // put placeholder at the end of cell queue when there're placeholders in the collection view
        // to avoid potential problems caused by placeholder API
        let destinationIndexPath: IndexPath
        if let destinationIndexPathTmp = coordinator.destinationIndexPath, !collectionView.hasUncommittedUpdates {
            destinationIndexPath = destinationIndexPathTmp
        } else {
            destinationIndexPath = IndexPath(item: collectionView.visibleCells.count, section: 0)
        }
        
        // goal: implement rearrangement
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    let imageARAndURL = imageARAndURLs.remove(at: sourceIndexPath.item)
                    imageARAndURLs.insert(imageARAndURL, at: min(destinationIndexPath.item, imageARAndURLs.count))
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else {
                let dropPlaceholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "dropPlaceholderCell")
                dropPlaceholder.cellUpdateHandler = { collectionViewCell in
                    if let placeholderCell = collectionViewCell as? DropPlaceholderCollectionViewCell {
                        placeholderCell.spinner.startAnimating()
                    }
                }
                let placeHolderContext = coordinator.drop(item.dragItem, to: dropPlaceholder)
                
                
                var imageARAndURL = [String: Any]()
                let group = DispatchGroup()
                group.enter()
                _ = item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    if let image = provider as? UIImage {
                        let aspectRatio = image.size.height / image.size.width
                        imageARAndURL["aspectRatio"] = aspectRatio
                        group.leave()
                    }
                }
                group.enter()
                _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) { (provider, error) in
                    if let url = provider {
                        imageARAndURL["imageURL"] = url.imageURL
                        group.leave()
                    }
                }

                group.notify(queue: .global(qos: .userInitiated)) {
                    if imageARAndURL["aspectRatio"] != nil && imageARAndURL["imageURL"] != nil {
                        let task = URLSession.shared.dataTask(with: imageARAndURL["imageURL"] as! URL) { data, response, error in
                            // not handling response and error here
                            DispatchQueue.main.async {
                                if let imageData = data {
                                    imageARAndURL["image"] = UIImage(data: imageData) ?? UIImage(named: "imageNotFound")
                                } else {
                                    imageARAndURL["image"] = UIImage(named: "imageNotFound")
                                }
                                placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                    self.imageARAndURLs.insert(imageARAndURL, at: insertionIndexPath.item)
                                })
                            }
                        }
                        task.resume()
                    } else {
                        placeHolderContext.deletePlaceholder()
                    }
                }
            }
        }
    }

    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
