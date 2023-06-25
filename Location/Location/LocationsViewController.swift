//
//  LocationsViewController.swift
//  Location
//
//  Created by Iwy2th on 25/06/2023.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
  // MARK: - Properties
  var managerObjectContext: NSManagedObjectContext!
  var locations = [Location]()
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
//    let entity = Location.entity()
//    fetchRequest.entity = entity
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    do {
      locations = try managerObjectContext.fetch(fetchRequest)
    } catch {
      fatalCoreDataError(error)
    }
  }
  // MARK: - TableViewDelegates
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locations.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
    let location = locations[indexPath.row]
    cell.configure(for: location)
    return cell
  }
}
