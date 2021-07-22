//
//  MapVCExtension.swift
//  treddit
//
//  Created by Andrew Krier on 4/22/21.
//

import UIKit
import MapKit

extension MapViewController {
    
    // MARK: Blur

    func applyBlurEffect(to view: UIView) {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRect(x: view.bounds.minX - 10.0, y: view.bounds.minY - 10.0, width: view.bounds.width + 20.0, height: view.bounds.height + 20.0)
        
        blurView.layer.cornerRadius = (view.bounds.height + 20) / 2.0
        blurView.layer.zPosition = -1
        blurView.isUserInteractionEnabled = false
        blurView.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 5.0
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.masksToBounds = false
        view.addSubview(blurView)
    }
    
    // MARK: Map Helpers
    
    func makeTrail() {
        guard let snapshotDark = snapshotDark,
              let snapshotLight = snapshotLight else { return }
        
        let trailImageLight = drawCoordinatesOnMapSnapshot(self.currentTrailCoordinates, snapshot: snapshotLight)
        let trailImageDark = drawCoordinatesOnMapSnapshot(self.currentTrailCoordinates, snapshot: snapshotDark)
        
        self.currentTrail = Trail.makeTrail(for: Profile.getCurrentLoggedInUser(), withCoordinates: self.currentTrailCoordinates, timestamps: self.currentTrailTimestamps, snapshotLight: trailImageLight, snapshotDark: trailImageDark)
        
        mapView.removeOverlays(mapView.overlays)
        self.performSegue(withIdentifier: "AddNewTrailSegue", sender: nil)
        self.snapshotDark = nil
        self.snapshotLight = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard CLLocationManager.locationServicesEnabled() else { return }
        guard locations.count > 0 else { return }
        currentLocation = locations[0].coordinate
        GlobalState.currLocation = currentLocation
        
        if currentlyRecordingTrail {
            currentTrailCoordinates.append(currentLocation)
            currentTrailTimestamps.append(Int(Date().timeIntervalSince1970 * 1000))
            let poly = MKPolyline(coordinates: currentTrailCoordinates, count: currentTrailCoordinates.count)
            mapView.addOverlay(poly, level: MKOverlayLevel.aboveRoads)
            
            recenterMap()
        }
        
        if !didSetInitialPosition {
            recenterMap()
            didSetInitialPosition = true
            saveMapSnapshotForBackground()
        }
    }
    
    func saveMapSnapshotForBackground() {
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        mapSnapshotOptions.region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapSnapshotOptions.traitCollection = UITraitCollection.init(userInterfaceStyle: .dark)
        mapSnapshotOptions.scale = UIScreen.main.scale

        mapSnapshotOptions.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        let mapSnapshotOptions2 = mapSnapshotOptions.copy() as! MKMapSnapshotter.Options
        mapSnapshotOptions2.traitCollection = UITraitCollection.init(userInterfaceStyle: .light)
        
        let snapShotter2 = MKMapSnapshotter(options: mapSnapshotOptions2)

        snapShotter.start() { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
            let background = snapshot.image
            saveImage(background, toFile: Strings.backgroundFilenameDark)
        }
        
        snapShotter2.start() { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
            let background = snapshot.image

            saveImage(background, toFile: Strings.backgroundFilenameLight)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0

        return renderer
    }
    
    func recenterMap() {
        mapView.setCenter(currentLocation, animated: true)
        
        let region = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        didSetInitialPosition = true
    }

}

