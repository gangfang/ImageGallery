//
//  GalleriesTableViewController.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/27.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit
// goal: tap a row to open the corresponding gallery with segue
class GalleriesTableViewController: UITableViewController {

    @IBAction func addGallery(_ sender: UIBarButtonItem) {
        galleries[GalleriesTableVarNames.mainSection]!.append(GalleriesTableVarNames.untitledGallery)
        tableView.reloadData()
    }
    var galleries: [String: [String]] = [GalleriesTableVarNames.mainSection: [GalleriesTableVarNames.untitledGallery],
                                         GalleriesTableVarNames.recentlyDeletedSection: []]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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
        cell.textLabel?.text = galleries[getGalleryTitle(from: indexPath.section)]![indexPath.row]
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
        let selectedRow = tableView.cellForRow(at: indexPath)
        if getGalleryTitle(from: indexPath.section) == GalleriesTableVarNames.mainSection {
            performSegue(withIdentifier: "showGallery", sender: selectedRow)
        }
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let selectedRow = sender as? UITableViewCell {
            print(selectedRow.textLabel?.text)
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
