//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/16.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    var images = [UIImage(named: "model3"), UIImage(named: "elon")]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
    
        if let imageCell = cell as? ImageCollectionViewCell, images[indexPath.item] != nil {
            imageCell.imageView.image = images[indexPath.item]
        }
        return cell
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
            dragItem.localObject = draggedImage
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
        return UICollectionViewDropProposal(operation: isDragFromWithin(of: session) ? .move: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    private func isDragFromWithin(of session: UIDropSession) -> Bool {
        return (session.localDragSession?.localContext as? UICollectionView) == collectionView
    }
    
    // to prevent app from crashing of 'attempt to begin reordering on collection view while reordering is already in progress'
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        collectionView.endInteractiveMovement()
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {     // try using func isDragFromWithin
                if let draggedImage = item.dragItem.localObject as? UIImage {
                    collectionView.performBatchUpdates({
                        images.remove(at: sourceIndexPath.item)     // to update the model
                        images.insert(draggedImage, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])   // to update the view
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath) // for animation
                }
            } else {
                let placeHolderContext = coordinator.drop(item.dragItem,
                                                          to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "dropPlaceholderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                self.images.insert(image, at: insertionIndexPath.item)
                            })
                        } else {
                            placeHolderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
