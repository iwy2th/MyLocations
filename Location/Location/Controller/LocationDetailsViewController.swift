// Core Location FrameWork
import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  print("******* Hey date da duoc call")
  return formatter
}()

class LocationDetailsViewController: UITableViewController {
  // MARK: - Properties
  var locationToEdit: Location? {
    didSet {
      if let locationToEdit {
        descriptionText = locationToEdit.locationDescription
        categoryName = locationToEdit.category
        date = locationToEdit.date
        coordinate = CLLocationCoordinate2DMake(locationToEdit.latitude, locationToEdit.longitude)
        placemark = locationToEdit.placemark 
      }
    }
  }
  var descriptionText = ""
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var date = Date()
  var categoryName = "No Category"
  var managedObjectContext: NSManagedObjectContext!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    if let locationToEdit {
      title = "Edit Location"
    }
    descriptionTextView.text = descriptionText
    categoryLabel.text = categoryName
    latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    if let placemark {
      addressLabel.text = string(from: placemark)
    } else {
      addressLabel.text = "No address Found"
    }
    dateLabel.text = format(date: date)
  // MARK: - Hide keyboard
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
  }
  // MARK: -  Done Cancel Button
  @IBAction func done() {
    guard let mainView = navigationController?.parent?.view
    else { return }
    let hudView = HudView.hud(inView: mainView, animated: true)
    let location: Location
    if let locationToEdit {
      hudView.text = "Update"
      location = locationToEdit
    } else {
      hudView.text = "Tagged"
      location = Location(context: managedObjectContext)
    }
    // Save Data
    location.locationDescription = descriptionTextView.text
    location.latitude = coordinate.latitude
    location.category = categoryName
    location.longitude = coordinate.longitude
    location.date = date
    location.placemark = placemark
    // Save Data throw error ?
    do {
      try managedObjectContext.save()
      afterDelay(0.6) {
        hudView.hide()
        self.navigationController?.popViewController(animated: true)
      }
    } catch {
      //  fatalError("error \(error)")
      fatalCoreDataError(error)
    }
  }
  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }
  // MARK: - Chang placemark -> String
  func string(from placemark: CLPlacemark) -> String {
    var text = ""
    if let tmp = placemark.subThoroughfare {
      text += tmp + " "
    }
    if let tmp = placemark.thoroughfare {
      text += tmp + ", "
    }
    if let tmp = placemark.locality {
      text += tmp + ", "
    }
    if let tmp = placemark.administrativeArea {
      text += tmp + " "
    }
    if let tmp = placemark.postalCode {
      text += tmp + ", "
    }
    if let tmp = placemark.country {
      text += tmp
    }
    return text
  }
  // MARK: - Date
  func format(date: Date) -> String {
    return dateFormatter.string(from: date)
  }
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destination as! CategoryPikerViewController
      controller.selectedCategoryName = categoryName
    }
  }
  @IBAction func categoryPickerDidCategory(_ segue: UIStoryboardSegue) {
    let controller = segue.source as! CategoryPikerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }
  // MARK: - Table ViewDelegate
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if indexPath.section == 0 || indexPath.section == 1 {
      return indexPath
    } else {
      return nil
    }
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.row == 0 {
      descriptionTextView.becomeFirstResponder()
    }
  }
  @objc func hideKeyboard(_ gestureRecognizer : UIGestureRecognizer) {
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    if indexPath != nil  && indexPath!.section == 0 && indexPath!.row == 0 {
      return
    }
    descriptionTextView.resignFirstResponder()
  }
}
