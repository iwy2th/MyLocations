//
//  LocationCell.swift
//  Location
//
//  Created by Iwy2th on 25/06/2023.
//

import UIKit

class LocationCell: UITableViewCell {
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  // MARK: - Properties
  override func awakeFromNib() {
    super.awakeFromNib()

  }
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  // MARK: - Description
  func configure(for location: Location) {
    if location.locationDescription.isEmpty {
      descriptionLabel.text = "(No Description)"
    } else {
      descriptionLabel.text = location.locationDescription
    }
    if let placemark = location.placemark {
          var text = " "
          if let tmp = placemark.subThoroughfare {
            text += tmp + " "
          }
          if let tmp = placemark.thoroughfare {
            text += tmp + ", "
          }
          if let tmp = placemark.locality {
            text += tmp
          }
          addressLabel.text = text
        } else {
          addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
    photoImageView.image = thumbnail(for: location)
  }
  // MARK: - Image
  func thumbnail(for location: Location) -> UIImage {
    if location.hasPhoto, let image = location.photoImage {
      return image.resized(withBounds: CGSize(width: 52, height: 52)) 
    }
    return UIImage()
  }

}

