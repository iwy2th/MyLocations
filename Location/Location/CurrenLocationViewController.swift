import UIKit
import CoreLocation
import CoreData

class CurrenLocationViewController: UIViewController, CLLocationManagerDelegate {
  var managedObjectContext: NSManagedObjectContext!
  let locationManager = CLLocationManager()
  var location: CLLocation?
  /** Handel error **/
  var updatingLocation = false
  var lastLocationError: Error?
  /** Reverse geocoding **/
  let geocoder = CLGeocoder()
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false
  var lastGeocodingError: Error?
  var timer: Timer?
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false 
  }
  @IBAction func GetLocation(_ sender: UIButton) {
    let authStatus = locationManager.authorizationStatus
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }
    if updatingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      placemark = nil
      lastLocationError = nil
      startLocationManager()
    }
    lastLocationError = nil
    updateLabels()
  }
  // MARK: - locationManager Delegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("*** didUpdateLocations \(newLocation)")
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
    if let location {
      distance = newLocation.distance(from: location)
    }
    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      lastLocationError = nil
      location = newLocation
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        print("*** We're done!")
        stopLocationManager()
        if distance > 0 {
          performingReverseGeocoding = false
        }
      }

      if !performingReverseGeocoding {
        print("*** Going to geocode")
        performingReverseGeocoding = true
        geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in
          self.lastGeocodingError = error
          if error == nil, let places = placemarks, !places.isEmpty {
           self.placemark = places.last!
          } else {
            self.placemark = nil
          }
          self.performingReverseGeocoding = false
          self.updateLabels()
        }
      }
      updateLabels()
    } else if distance < 1 {
      let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
      if timeInterval > 10 {
        print("*** Force done!")
        stopLocationManager()
        updateLabels()
      }
    }
  }
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    // Đối tượng Error có domain and code 
    print("*** didFailWithError \(error.localizedDescription)")
    print("***__***\((error as NSError).code)")
    if (error as NSError).code == CLError.locationUnknown.rawValue {
      return
    }
    lastLocationError = error
    stopLocationManager()
    updateLabels()
  }
  // MARK: - showAlertError
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable seevices for this app in Settings", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)

  }
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true
      timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
    }
  }
  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
      if let timer {
        timer.invalidate()
      }
    }
  }
  func updateLabels() {
    if let location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.isHidden = false
      messageLabel.text = ""
      if let placemark {
        addressLabel.text = string(from: placemark)
      } else if performingReverseGeocoding {
        addressLabel.text = "Searching for Address..."
      } else if lastGeocodingError != nil {
        addressLabel.text = "Error Finding Address"
      } else {
        addressLabel.text = "No Address Found"
      }
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.isHidden = true
      let statusMessage: String
      if let error = lastLocationError as NSError? {
        if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
          statusMessage = "Location Services Disabled"
        } else {
          statusMessage = "Error Getting Location"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        statusMessage = "Location Services Disabled"
      } else if updatingLocation {
        statusMessage = "Searching..."
      } else {
        statusMessage = "Tap 'Get My Location' to Start"
      }
      messageLabel.text = statusMessage
    }
    configureGetButton()
  }
  func configureGetButton() {
    if updatingLocation {
      getButton.setTitle("Stop", for: .normal)
    } else {
      getButton.setTitle("Get My Location", for: .normal)
    }
  }
  func string(from placemark: CLPlacemark) -> String {
    var line1 = ""
    if let tmp = placemark.subThoroughfare {
      line1 += tmp + " "
    }
    if let tmp = placemark.thoroughfare {
      line1 += tmp
    }
    var line2 = ""
    if let tmp = placemark.locality {
      line2 += tmp + " "
    }
    if let tmp = placemark.administrativeArea {
      line2 += tmp + " "
    }
    if let tmp = placemark.postalCode {
      line2 += tmp
    }
    return line1 + "\n" + line2
  }
  @objc func didTimeOut() {
    print("*** Time out")
    if location == nil {
      stopLocationManager()
      lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
      updateLabels()
    }
  }
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "TagLocation" {
      let controller = segue.destination as! LocationDetailsViewController
      controller.coordinate = location!.coordinate
      controller.placemark = placemark
      controller.managedObjectContext = managedObjectContext
    }
  }
}

