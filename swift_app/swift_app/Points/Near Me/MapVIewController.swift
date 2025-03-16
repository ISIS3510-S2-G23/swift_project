//
//  MapViewController.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/15/25.
//

import UIKit
import MapKit

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
        
        // Set an initial location (DO NOT CHANGE)
        let initialLocation = CLLocationCoordinate2D(latitude: 4.602978147636273, longitude: -74.06520670796498)
        let region = MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.0015, longitudeDelta: 0.0015)
        )
        mapView.setRegion(region, animated: true)
        
        // Add predefined locations (Recycle Points)
        let locations: [(name: String, latitude: Double, longitude: Double)] = [
            ("Recycling Center 1", 4.602800347961165, -74.0659410545649),
            ("Recycling Center 2", 4.60349359373104, -74.06544967642769),
            ("Eco Point", 4.603940686676833, -74.06591333578002)
        ]

        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotation.title = location.name
            annotation.subtitle = "Recycle Point"
            mapView.addAnnotation(annotation)
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
