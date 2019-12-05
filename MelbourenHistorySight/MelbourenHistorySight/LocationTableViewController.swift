//
//  LocationTableViewController.swift
//  MelbourenHistorySight
//
//  Created by Lynn on 4/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {


    let CELL_SIGHT = "sightCell"
    var mapViewController: MapViewController?
    var locationList = [Sight]()
    var currentParty:[Sight] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil);
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sight"
        navigationItem.searchController = searchController
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            currentParty = locationList.filter({(sight: Sight) -> Bool in
                return sight.name!.contains(searchText)
            })
        }
        else {
            currentParty = locationList;
        }
        
        tableView.reloadData();
    }
    
    @IBAction func AtoZ(_ sender: Any) {
        currentParty.sort(by:{ $0.name!.compare($1.name!) == ComparisonResult.orderedAscending})
        tableView.reloadData()
    }
    @IBAction func ZtoA(_ sender: Any) {
        currentParty.sort(by:{ $0.name!.compare($1.name!) == ComparisonResult.orderedDescending})
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentParty.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sightCell = tableView.dequeueReusableCell(withIdentifier: CELL_SIGHT, for: indexPath) as!
        SightTableViewCell
        let sight = currentParty[indexPath.row]
        //123
        
        sightCell.nameLabel.text = sight.name
        sightCell.decriptionLabel.text = sight.desc
        var icon: String = sight.icon!
        sightCell.imageIcon.image = UIImage(named: icon)
        
        return sightCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapViewController?.focusOn(annotation: LocationAnnotation( sight: self.locationList[indexPath.row]))
        navigationController?.popViewController(animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
            return
        }
    // MARK: - Database Listener
    
    var listenerType = ListenerType.sight

    func onSightListChange(change: DatabaseChange, sight: [Sight]) {
        locationList = sight
        updateSearchResults(for: navigationItem.searchController!)
    }
   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delect the row from the database
            let _ = databaseController!.deleteSight(sight: self.currentParty[indexPath.row])
            // Delete the row from the data source
            self.currentParty.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateSearchResults(for: navigationItem.searchController!)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
