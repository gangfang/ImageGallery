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
       let destinationIndexPath = configureDestinationIndexPath(collectionView, coordinator)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                move(item, in: collectionView, from: sourceIndexPath, to: destinationIndexPath, with: coordinator)
            } else {
                copy(item, into: collectionView, dropAt: destinationIndexPath, with: coordinator)
            }
        }
    }

    // put placeholder at the end of cell queue when there're placeholders in the collection view
    // to avoid potential problems caused by placeholder API
    private func configureDestinationIndexPath(_ collectionView: UICollectionView, _ coordinator: UICollectionViewDropCoordinator) -> IndexPath {
        if let destinationIndexPathTmp = coordinator.destinationIndexPath, !collectionView.hasUncommittedUpdates {
            return destinationIndexPathTmp
        } else {
            return IndexPath(item: collectionView.visibleCells.count, section: 0)
        }
    }
    
    private func move(_ item: UICollectionViewDropItem,
                      in collectionView: UICollectionView,
                      from sourceIndexPath: IndexPath,
                      to destinationIndexPath: IndexPath,
                      with coordinator: UICollectionViewDropCoordinator)
    {
        collectionView.performBatchUpdates({
        let imageARAndURL = imageARAndURLs.remove(at: sourceIndexPath.item)
        imageARAndURLs.insert(imageARAndURL, at: min(destinationIndexPath.item, imageARAndURLs.count))
        collectionView.deleteItems(at: [sourceIndexPath])
        collectionView.insertItems(at: [destinationIndexPath])
        })
        coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
    }
    
    private func copy(_ item: UICollectionViewDropItem,
                      into collectionView: UICollectionView,
                      dropAt destinationIndexPath: IndexPath,
                      with coordinator: UICollectionViewDropCoordinator)
    {
        var imageARAndURL = [String: Any]()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        _ = item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
            if let image = provider as? UIImage {
                let aspectRatio = image.size.height / image.size.width
                imageARAndURL["aspectRatio"] = aspectRatio
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        _ = item.dragItem.itemProvider.loadObject(ofClass: URL.self) { (provider, error) in
            if let url = provider {
                imageARAndURL["imageURL"] = url.imageURL
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let dropPlaceholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "dropPlaceholderCell")
            dropPlaceholder.cellUpdateHandler = { collectionViewCell in
                if let placeholderCell = collectionViewCell as? DropPlaceholderCollectionViewCell {
                    placeholderCell.spinner.startAnimating()
                }
            }
            let placeHolderContext = coordinator.drop(item.dragItem, to: dropPlaceholder)
            
            if imageARAndURL["aspectRatio"] != nil && imageARAndURL["imageURL"] != nil {
                let task = URLSession.shared.dataTask(with: imageARAndURL["imageURL"] as! URL) { data, response, error in
                    // not handling response and error 
                    DispatchQueue.main.async {
                        if let imageData = data, let image = UIImage(data: imageData) {
                            imageARAndURL["image"] = image
                        } else {
                            imageARAndURL["image"] = UIImage(named: "imageNotFound")
                            imageARAndURL["aspectRatio"] = CGFloat(1)
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
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
