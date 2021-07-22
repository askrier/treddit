//
//  TrailExtension.swift
//  treddit
//
//  Created by Andrew Krier on 4/22/21.
//

import UIKit
import MapKit

extension Trail {
    
    // MARK: Trail Management
    
    static func makeTrail(for person: Profile,
                          withCoordinates coordinates: [CLLocationCoordinate2D],
                          timestamps: [Int],
                          snapshotLight imageLight: UIImage,
                          snapshotDark imageDark: UIImage) -> Trail {
        let newTrail = Trail()
        
        newTrail.trailCoordinates = coordinates
        newTrail.trailTimestamps = timestamps
        newTrail.trailImageLight = imageLight
        newTrail.trailImageDark = imageDark
        newTrail.trailOwnerUserID = person.userID
        newTrail.trailSubmissionTimeStamp = Int(Date().timeIntervalSince1970 * 1000)
        
        return newTrail
    }
    
    static func findTrail(ownedBy user: Profile, completedAt timestamp: Int) -> Trail? {
        let results = GlobalState.allTrails.filter { $0.trailOwnerUserID == user.userID && $0.trailSubmissionTimeStamp == timestamp }
        
        return results.count > 0 ? results[0] : nil
    }
    
    static func loadAllTrails() {
        let trailsFilepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("trails")
        
        
        let jsonDecoder = JSONDecoder()
        if let data = try? Data.init(contentsOf: trailsFilepath) {
            if let allTrails = try? jsonDecoder.decode([Trail].self, from: data) {
                GlobalState.allTrails = allTrails
            }
        }
    }
    
    // MARK: JSON
    
    func save() {
        if Trail.findTrail(ownedBy: Profile.getUserByID(self.trailOwnerUserID)!, completedAt: trailSubmissionTimeStamp) == nil {
            GlobalState.allTrails.append(self)
        }
        
        GlobalState.save()
    }
    
    static func saveAllTrailsToDisk() {
        let trailsFilepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("trails")

        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(GlobalState.allTrails) {
            try? data.write(to: trailsFilepath)
        }
    }
    
    // MARK: Misc
    
    func distanceFromMiles(_ from : CLLocationCoordinate2D) -> Double {
        let to = CLLocation(latitude: trailCoordinates[0].latitude, longitude: trailCoordinates[0].longitude)
        let fr = CLLocation(latitude: from.latitude, longitude: from.longitude)
        return to.distance(from: fr) * 0.000621
    }
    
}
