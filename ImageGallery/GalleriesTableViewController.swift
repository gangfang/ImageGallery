//
//  GalleriesTableViewController.swift
//  ImageGallery
//
//  Created by GANG_FANG on 2018/10/27.
//  Copyright © 2018 gfang. All rights reserved.
//

import UIKit
// goal: swipe to delete in main section
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
    
    private func getGalleryTitle(from number: Int) -> String {
        switch number {
        case 0:
            return GalleriesTableVarNames.mainSection
        case 1:
            return GalleriesTableVarNames.recentlyDeletedSection
        default:
            assertionFailure("number returned from indexPath.section is unexpected in getGalleryTitle(from)")
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
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


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .fade)
                if getGalleryTitle(from: indexPath.section) == GalleriesTableVarNames.mainSection {
                    tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                    let tempDeletedGallery = galleries[GalleriesTableVarNames.mainSection]!.remove(at: indexPath.row)
                    galleries[GalleriesTableVarNames.recentlyDeletedSection]!.insert(tempDeletedGallery, at: 0)
                } else if getGalleryTitle(from: indexPath.section) == GalleriesTableVarNames.recentlyDeletedSection {
                    galleries[GalleriesTableVarNames.recentlyDeletedSection]!.remove(at: indexPath.row)
                }
            })
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


struct GalleriesTableVarNames {
    static let mainSection = "main"
    static let recentlyDeletedSection = "recentlyDeleted"
    static let untitledGallery = "Untitled Gallery"
}
