//
//  GlobalState.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 10/4/21.
//

import Firebase
import Foundation
import MapKit

class GlobalState {
    static var allTrails: [Trail] = []
    static var allPeople: [Profile] = []
    static let storage = Storage.storage()
    static let storageRef = storage.reference().child("alldata.json")
    static var trailTableViews: [TrailDisplayer] = []
    static var currLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    static func save() {
        let fullState = FullState()
        fullState.allTrails = allTrails
        fullState.allPeople = allPeople
        
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        metadata.cacheControl = "public,max-age=0"
        
        let uploadTask = storageRef.putData(fullState.asJSON(), metadata: metadata) { (metadata, error) in
            guard let _ = metadata else { return }
            
            storageRef.downloadURL { (url, error) in
                guard let _ = url else { return }
            }
        }
        uploadTask.resume()
        
        Profile.saveAllProfilesToDisk()
        Trail.saveAllTrailsToDisk()
    }
    
    static func sync(_ after: @escaping () -> Void) {
        Profile.loadAllProfiles()
        Trail.loadAllTrails()
        
        let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tempdata")
        try? FileManager.default.removeItem(at: localURL)

        let downloadTask = storageRef.write(toFile: localURL) { url, error in
            if let _ = error {
                print("Error!")
            } else {
                let jsonDecoder = JSONDecoder()
                if let data = try? Data.init(contentsOf: localURL) {
                    if let fullState = try? jsonDecoder.decode(FullState.self, from: data) {
                        GlobalState.allTrails = fullState.allTrails!
                        GlobalState.allPeople = fullState.allPeople!
                        GlobalState.trailTableViews.forEach { $0.reloadTable() }
                        
                        Profile.saveAllProfilesToDisk()
                        Trail.saveAllTrailsToDisk()
                        after()
                    }
                }
            }
        }
        downloadTask.resume()
    }
}
