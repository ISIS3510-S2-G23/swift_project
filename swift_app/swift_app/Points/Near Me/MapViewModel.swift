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
import Network

@MainActor
class MapViewModel: UIViewController, @preconcurrency CLLocationManagerDelegate, ObservableObject {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    @Published var locations: [MKPointAnnotation] = []
    @Published var locationsLoaded: Bool = false
    
    private let networkMonitor = NWPathMonitor()
    @Published private(set) var isConnected = true
    
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
        
        // Setup location manager
        setupLocationManager()
        
        // Enable user tracking
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // Check if we already have a location
        if let userLocation = locationManager.location {
            centerMapOnLocation(userLocation)
        }
        
        setupNetworkMonitoring()
        
        // Fetch locations asynchronously if not already loaded
        if !locationsLoaded {
            Task {
                await fetchLocations()
            }
        }
        else {
            paintLocations()
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = (path.status == .satisfied)
                if !wasConnected && self?.isConnected == true {
                    print("Network reconnected, refreshing data...")
                    Task { [weak self] in
                                        guard let self else { return }
                                        await self.fetchLocations()
                                    }
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
    
    func paintLocations() {
        let locationCount = locations.count
        for i in 0..<locationCount {
            let annotation = locations[i]
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        }
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
            print("Location access granted")
            locationManager.startUpdatingLocation()
            
            // Immediately center map if location is available
            if let userLocation = locationManager.location {
                centerMapOnLocation(userLocation)
            }
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            print("Waiting for user to grant permission")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        centerMapOnLocation(userLocation)
    }
    
    func fetchLocations() async {
        print("STARTED FETCHING LOCATIONS")
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("locations").getDocuments()
            if snapshot.isEmpty {
                print("No locations found")
                return
            }
            
            // Prepare new annotations
            var newAnnotations: [MKPointAnnotation] = []

            let docs = snapshot.documents
            let count = docs.count

            for i in 0..<count {
                let data = docs[i].data()
                
                if let name = data["name"] as? String,
                   let geoPoint = data["location"] as? GeoPoint {
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(
                        latitude: geoPoint.latitude,
                        longitude: geoPoint.longitude
                    )
                    annotation.title = name
                    annotation.subtitle = "Recycle Point"
                    
                    newAnnotations.append(annotation)
                    print("FETCHED \(annotation)")
                }
            }

            // Apply updates in one main-thread block
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(newAnnotations)
                self.locations = newAnnotations
                self.locationsLoaded = true
                print("FINISHED FETCHING LOCATIONS")
            }
            
        } catch {
            print("Error fetching locations: \(error)")
        }
    }
}




// MARK: - SwiftUI Wrapper for MapViewController
import SwiftUI

struct MapViewModelWrapper: UIViewControllerRepresentable {
    @ObservedObject var mapViewModel = MapViewModel()  // Use StateObject here
    
    func makeUIViewController(context: Context) -> MapViewModel {
        return mapViewModel  // Return the same mapViewModel object
    }

    func updateUIViewController(_ uiViewController: MapViewModel, context: Context) {
        // No update needed for static map, it's managed within MapViewModel
    }
}

