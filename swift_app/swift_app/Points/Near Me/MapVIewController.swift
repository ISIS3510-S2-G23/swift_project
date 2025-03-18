//
//  MapViewController.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/15/25.
//

import UIKit
import MapKit
import FirebaseFirestore

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    
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
        
        // Set initial location (DO NOT CHANGE)
        let initialLocation = CLLocationCoordinate2D(latitude: 4.602978147636273, longitude: -74.06520670796498)
        let region = MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
        )
        mapView.setRegion(region, animated: true)
        
        // Fetch and display locations from Firebase
        fetchLocations()
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
            
            // Remove existing annotations before adding new ones
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
            
            for document in documents {
                let data = document.data()
                
                if let name = data["name"] as? String,
                   let geoPoint = data["location"] as? GeoPoint { // Extract GeoPoint
                    
                    let latitude = geoPoint.latitude
                    let longitude = geoPoint.longitude
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    annotation.title = name
                    annotation.subtitle = "Recycle Point"
                    
                    print("Added Location: \(name) at (\(latitude), \(longitude))")
                    
                    // Add to map on main thread
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
