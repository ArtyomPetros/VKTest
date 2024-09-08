import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let locationLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont.boldSystemFont(ofSize: 24)
        locationLabel.textColor = .white
        view.addSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50)
        ])
    }

    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            locationLabel.text = "Location services are disabled"
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Convert coordinates to city name
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error)")
                self?.locationLabel.text = "Failed to determine location"
                return
            }
            
            if let placemark = placemarks?.first, let city = placemark.locality {
                self?.locationLabel.text = "Город: \(city)"
                self?.updateBackgroundColor()
            } else {
                self?.locationLabel.text = "Failed to determine city"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager error: \(error)")
        locationLabel.text = "Failed to determine location"
    }
    
    func updateBackgroundColor() {
        let randomColor = UIColor(
            red: CGFloat(arc4random_uniform(256)) / 255.0,
            green: CGFloat(arc4random_uniform(256)) / 255.0,
            blue: CGFloat(arc4random_uniform(256)) / 255.0,
            alpha: 1.0
        )
        UIView.animate(withDuration: 1.5) {
            self.view.backgroundColor = randomColor
        }
    }
}
