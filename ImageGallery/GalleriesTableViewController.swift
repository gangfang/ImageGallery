//
//  GalleriesTableViewController.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/27.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit

class GalleriesTableViewController: UITableViewController, UISplitViewControllerDelegate {

    @IBAction func addGallery(_ sender: UIBarButtonItem) {
        galleries[GalleriesTableVarNames.mainSection]!.append(getAnEmptyImageGallery())
        tableView.reloadData()
        
        selectNewlyAddedGalleryRow()
    }
    
    private func selectNewlyAddedGalleryRow() {
        let numberOfMainGalleries = tableView.numberOfRows(inSection: getGalleryIdx(from: GalleriesTableVarNames.mainSection))
        let newlyAddedGalleryRowIndexPath = IndexPath(row: numberOfMainGalleries - 1, section: getGalleryIdx(from: GalleriesTableVarNames.mainSection))
        selectRow(at: newlyAddedGalleryRowIndexPath)
    }
    
    lazy var galleries: [String: [ImageGallery]] = [GalleriesTableVarNames.mainSection: [getAnEmptyImageGallery()],
                                                    GalleriesTableVarNames.recentlyDeletedSection: []]

    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectFirstRowOnLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    /// set preferredDisplayMode as primaryOverlay
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let splitViewController = splitViewController, splitViewController.preferredDisplayMode != .primaryOverlay {
            splitViewController.preferredDisplayMode = .primaryOverlay
        }
    }
    
    private func selectFirstRowOnLoad() {
        selectRow(at: IndexPath(row: 0, section: 0))
    }
    
    private func selectRow(at indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        tableView(tableView, didSelectRowAt: indexPath)
    }
    
    private func getAnEmptyImageGallery() -> ImageGallery {
        return ImageGallery(name: "Untitled Gallery", images: [])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries[getGalleryTitle(from: section)]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleryRow", for: indexPath)
        if let galleryRowCell = cell as? GalleriesTableViewCell {
            galleryRowCell.textField.text = galleries[getGalleryTitle(from: indexPath.section)]![indexPath.row].name
            galleryRowCell.textField.isEnabled = getGalleryTitle(from: indexPath.section) == GalleriesTableVarNames.mainSection
            galleryRowCell.resignationHandler = { [weak self, unowned galleryRowCell] in
                if let text = galleryRowCell.textField.text {
                    self?.galleries[self!.getGalleryTitle(from: indexPath.section)]![indexPath.row].name = text
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case getGalleryIdx(from: GalleriesTableVarNames.mainSection):
            return nil
        case getGalleryIdx(from: GalleriesTableVarNames.recentlyDeletedSection):
            return "Recently Deleted"
        default:
            assertionFailure("number returned from indexPath.section is unexpected in tableView(_:titleForHeaderInSection)")
            return nil
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /// func implementing swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .fade)
                if getGalleryTitle(from: indexPath.section) == GalleriesTableVarNames.mainSection {
                    tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                    let galleryToDelete = galleries[GalleriesTableVarNames.mainSection]!.remove(at: indexPath.row)
                    galleries[GalleriesTableVarNames.recentlyDeletedSection]!.insert(galleryToDelete, at: 0)
                } else if getGalleryTitle(from: indexPath.section) == GalleriesTableVarNames.recentlyDeletedSection {
                    galleries[GalleriesTableVarNames.recentlyDeletedSection]!.remove(at: indexPath.row)
                }
            })
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /// func implementing swipe to undelete
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == getGalleryIdx(from: GalleriesTableVarNames.recentlyDeletedSection) {
            let undeleteAction = UIContextualAction(style: .normal, title: "Undelete") { (_, _, _) in
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    let galleryToUndelete = self.galleries[GalleriesTableVarNames.recentlyDeletedSection]!.remove(at: indexPath.row)
                    self.galleries[GalleriesTableVarNames.mainSection]!.insert(galleryToUndelete, at: 0)
                    
                    // to avoid the bug which causes "Undelete" button to stay on screen after the Undeletion is completed
                    tableView.reloadData()
                })
            }
            return UISwipeActionsConfiguration(actions: [undeleteAction])
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showGallery", sender: indexPath)
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath, let destinationNavigationVC = segue.destination as? UINavigationController {
            if let mainGalleries = galleries[GalleriesTableVarNames.mainSection], !mainGalleries.isEmpty {
                let imageGalleryCollectionVC = destinationNavigationVC.topViewController as! ImageGalleryCollectionViewController
                imageGalleryCollectionVC.imageGallery = mainGalleries[indexPath.row]
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = sender as? IndexPath {
            return getGalleryTitle(from: indexPath.section) == GalleriesTableVarNames.mainSection
        } else {
            assertionFailure("sender as? IndexPath casting failed.")
            return false
        }
    }

    
    
    private func getGalleryTitle(from idx: Int) -> String {
        switch idx {
        case 0:
            return GalleriesTableVarNames.mainSection
        case 1:
            return GalleriesTableVarNames.recentlyDeletedSection
        default:
            assertionFailure("number returned from indexPath.section is unexpected in getGalleryTitle(from)")
            return ""
        }
    }
    private func getGalleryIdx(from title: String) -> Int {
        switch title {
        case GalleriesTableVarNames.mainSection:
            return 0
        case GalleriesTableVarNames.recentlyDeletedSection:
            return 1
        default:
            assertionFailure("number returned from indexPath.section is unexpected in getGalleryIdx(from)")
            return 0
        }
    }
}


struct GalleriesTableVarNames {
    static let mainSection = "main"
    static let recentlyDeletedSection = "recentlyDeleted"
    static let untitledGallery = "Untitled Gallery"
}
