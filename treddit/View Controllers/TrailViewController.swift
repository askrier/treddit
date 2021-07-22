//
//  TrailViewController.swift
//  treddit
//
//  Created by Andrew Krier on 3/30/21.
//

import UIKit
import MapKit

class TrailViewController: UIViewController,
                           MKMapViewDelegate {
    
    // MARK: Definitions and IB's
    
    var currentTrail: Trail!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var playingRoute = false
    var latestQualifingTimestampForDisplay = 0
    var timer = Timer()
    
    // MARK: View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepKeyboard()
        
        if currentTrail.trailOwnerUserID != Profile.getCurrentLoggedInUser().userID {
            editButton.isHidden = true
        }
        
        styleFormButton(playPauseButton, accented: false)
        styleFormButton(stopButton, accented: false)
        
        mapView.layoutMargins.bottom = -100
        mapView.layoutMargins.top = -100
        mapView.delegate = self
        
        mapView.removeOverlays(mapView.overlays)
        overlayTrail(currentTrail.trailCoordinates)
    }
    
    override func viewDidLayoutSubviews() {
        styleFormButton(editButton, accented: true)
        styleFormButton(backButton, accented: false)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0

        return renderer
    }
    
    // MARK: Button Handlers
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditTrailSegue",
           let destination = segue.destination as? EditTrailViewController {
            destination.trail = currentTrail
        }
    }

    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if playingRoute {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playingRoute = false
            timer.invalidate()
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playingRoute = true

            if latestQualifingTimestampForDisplay == 0 {
                latestQualifingTimestampForDisplay = currentTrail.trailTimestamps[0]
                mapView.removeOverlays(mapView.overlays)
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updatePlayedRoute), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        playingRoute = false
        latestQualifingTimestampForDisplay = 0
        
        mapView.removeOverlays(mapView.overlays)
        overlayTrail(currentTrail.trailCoordinates)
        timer.invalidate()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }

    @objc func updatePlayedRoute(){
        let qualifyingTimestamps = currentTrail.trailTimestamps.filter { $0 <= latestQualifingTimestampForDisplay }
        latestQualifingTimestampForDisplay += 1000
        overlayTrail(Array(currentTrail.trailCoordinates[0..<qualifyingTimestamps.count]))
        
        if qualifyingTimestamps.count == currentTrail.trailTimestamps.count {
            stopButtonPressed(self)
        }
    }
    
    func overlayTrail(_ coordinates: [CLLocationCoordinate2D]) {
        let poly = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(poly, level: MKOverlayLevel.aboveRoads)
        
        let rect = poly.boundingMapRect.union(poly.boundingMapRect.offsetBy(dx: -300, dy: -300)).union(poly.boundingMapRect.offsetBy(dx: 300, dy: 300))
        let region = MKCoordinateRegion(rect)
        mapView.setRegion(region, animated: true)
    }
    
}
