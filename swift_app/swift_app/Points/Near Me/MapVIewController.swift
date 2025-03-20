//
//  MapViewController.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/15/25.
//

import UIKit
import MapKit
import FirebaseFirestore
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        
        // Enable Auto Layout
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Setup location manager first
        setupLocationManager()
        
        // Enable user tracking
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // Check if we already have a location
        if let userLocation = locationManager.location {
            centerMapOnLocation(userLocation)
        }
        
        // Fetch and display locations from Firebase
        fetchLocations()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Add a helper function to center the map
    func centerMapOnLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Location access granted")
            locationManager.startUpdatingLocation()
            
            // Immediately center map if location is available
            if let userLocation = locationManager.location {
                centerMapOnLocation(userLocation)
            }
        case .denied, .restricted:
            print("❌ Location access denied")
        case .notDetermined:
            print("⏳ Waiting for user to grant permission")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        centerMapOnLocation(userLocation)
    }
    
    func fetchLocations() {
        let db = Firestore.firestore()
        
        db.collection("locations").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching locations: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No locations found")
                return
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            
            for document in documents {
                let data = document.data()
                
                if let name = data["name"] as? String,
                   let geoPoint = data["location"] as? GeoPoint {
                    
                    let latitude = geoPoint.latitude
                    let longitude = geoPoint.longitude
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = name
                    annotation.subtitle = "Recycle Point"
                    
                    print("Added Location: \(name) at (\(latitude), \(longitude))")
                    
                    DispatchQueue.main.async {
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
}


// MARK: - SwiftUI Wrapper for MapViewController
import SwiftUI

struct MapViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }

    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        // No update needed for a static map
    }
}
