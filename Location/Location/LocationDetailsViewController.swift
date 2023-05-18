// Core Location FrameWork
import UIKit
import CoreLocation
private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  print("******* Hey date da duoc call")
  return formatter
}()
class LocationDetailsViewController: UITableViewController {
  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    descriptionTextView.text = ""
    categoryLabel.text = categoryName
    latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    if let placemark {
      addressLabel.text = string(from: placemark)
    } else {
      addressLabel.text = "No address Found"
    }
    dateLabel.text = format(date: Date())
    // MARK: - Hide keyboard
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
  }

  @IBAction func done() {
    guard let mainView = navigationController?.parent?.view
    else { return }
    let hudView = HudView.hud(inView: mainView, animated: true)
    hudView.text = "Tagged"
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
