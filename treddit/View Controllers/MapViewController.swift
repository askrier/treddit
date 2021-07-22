//
//  MapViewController.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 28/3/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController,
                         CLLocationManagerDelegate,
                         MKMapViewDelegate {
    
    // MARK: Definitions
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recenterButton: UIButton!
    @IBOutlet weak var startStopHikeButton: UIButton!
    
    let locationManager = CLLocationManager()
    var didSetInitialPosition = false
    var currentLocation: CLLocationCoordinate2D!
    var currentlyRecordingTrail = false
    var currentTrailCoordinates: [CLLocationCoordinate2D] = []
    var currentTrailTimestamps: [Int] = []
    var currentTrail: Trail?
    var snapshotLight, snapshotDark: MKMapSnapshotter.Snapshot?
    
    // MARK: View Management

    override func viewDidLoad() {
        super.viewDidLoad()
        prepKeyboard()
        mapView.layoutMargins.bottom = -100
        mapView.layoutMargins.top = -100
        mapView.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        styleFormButton(startStopHikeButton, accented: false)
        styleFormButton(recenterButton, accented: false)
    }
    
    // MARK: Button Actions
    
    @IBAction func recenterButtonClicked(_ sender: Any) {
        recenterMap()
    }
    
    // This function is the majority of the trail drawing code
    @IBAction func startStopHikeButtonClicked(_ sender: Any) {
        if currentlyRecordingTrail {
            startStopHikeButton.setTitle("Start Hike", for: .normal)
            currentlyRecordingTrail = false
            guard !currentTrailCoordinates.isEmpty else { return }
            
            let mapSnapshotOptions = MKMapSnapshotter.Options()
            mapSnapshotOptions.traitCollection = UITraitCollection.init(userInterfaceStyle: .light)
            let polyLine = MKPolyline(coordinates: currentTrailCoordinates, count: currentTrailCoordinates.count)
            let region = MKCoordinateRegion(polyLine.boundingMapRect)
            mapSnapshotOptions.region = region
            mapSnapshotOptions.scale = UIScreen.main.scale

            mapSnapshotOptions.size = CGSize(width: 1600, height: 900)
            mapSnapshotOptions.showsBuildings = true

            let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
            
            let mapSnapshotOptions2 = mapSnapshotOptions.copy() as! MKMapSnapshotter.Options
            mapSnapshotOptions2.traitCollection = UITraitCollection.init(userInterfaceStyle: .dark)
            
            let snapShotter2 = MKMapSnapshotter(options: mapSnapshotOptions2)
            
            snapShotter.start() { snapshot, error in
                guard let snapshot = snapshot else {
                    return
                }
                self.snapshotLight = snapshot
            }
            
            snapShotter2.start() { snapshot, error in
                guard let snapshot = snapshot else {
                    return
                }
                
                self.snapshotDark = snapshot
                self.makeTrail()
            }
        } else {
            startStopHikeButton.setTitle("Stop Hike", for: .normal)
            currentlyRecordingTrail = true
            currentTrailTimestamps = []
            currentTrailCoordinates = []
        }
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewTrailSegue" {
            (segue.destination as! EditTrailViewController).trail = currentTrail
        }
    }

}
