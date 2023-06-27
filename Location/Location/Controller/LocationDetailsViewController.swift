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
  var image: UIImage?
  var observer: Any!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var addPhotoLabel: UILabel!
  @IBOutlet var imageHeight: NSLayoutConstraint!
  // MARK: - Methods
  func show(image: UIImage) {
    imageView.image = image
    imageView.isHidden = false
    addPhotoLabel.text = ""
    imageHeight.constant = 260
    tableView.reloadData()
  }
  func listenForBackgroundNotification() {

    observer = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
      if let weakSelf = self {
        if weakSelf.presentedViewController != nil {
          weakSelf.dismiss(animated: false)
        }
        weakSelf.descriptionTextView.resignFirstResponder()
      }
    }
  }
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    if let locationToEdit {
      title = "Edit Location"
      if locationToEdit.hasPhoto {
        if let theImage = locationToEdit.photoImage {
          show(image: theImage)
        }
      }
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
   // listenForBackgroundNotification()
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
      location.photoID = nil
    }
    // Save Data
    location.locationDescription = descriptionTextView.text
    location.latitude = coordinate.latitude
    location.category = categoryName
    location.longitude = coordinate.longitude
    location.date = date
    location.placemark = placemark
    if let image = image {
      if !location.hasPhoto {
        location.photoID = Location.nextPhotoID() as NSNumber
      }
      if let data = image.jpegData(compressionQuality: 0.5) {
        do {
          try data.write(to: location.photoURL, options: .atomic)
        } catch {
          print("Error writing file: \(error)")
        }
      }
    }
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
    } else if indexPath.section == 1 && indexPath.row == 0 {
      tableView.deselectRow(at: indexPath, animated: true)
     pickPhoto()
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
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  // MARK: - Image Helper Methods
  func takePhotoWithCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    present(imagePicker, animated: true)
  }
  // MARK: - Image Picker Delegates
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
    if let theImage = image {
      show(image: theImage)
    }
    dismiss(animated: true)
  }
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
  }
  // MARK: - Use Library to add image
  func choosePhotoFromLibrary() {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    present(imagePicker, animated: true)
  }
  // MARK: - Menu Photo
  func pickPhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      showPhotoMenu()
    } else {
      choosePhotoFromLibrary()
    }
  }
  func showPhotoMenu() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
      self.takePhotoWithCamera()
    }))
    alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { _ in
      self.choosePhotoFromLibrary()
    }))
    present(alert, animated: true)
  }
}
