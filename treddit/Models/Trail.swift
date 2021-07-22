//
//  Trail.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 10/4/21.
//

import UIKit
import MapKit

class Trail: Codable {
    
    // MARK: Definition
    
    var trailImageLight: UIImage!
    var trailImageDark: UIImage!
    var trailTitle = ""
    var trailOwnerUserID: Int!
    var trailLikes = 0
    var trailSubmissionTimeStamp: Int!
    var trailPublic = false
    var trailCoordinates: [CLLocationCoordinate2D]!
    var trailTimestamps: [Int]!
    var trailId: String {
        get {
            return "\(String(trailOwnerUserID!)):\(String(trailSubmissionTimeStamp!))"
        }
    }
    
    // MARK: Codability
    
    enum CodingKeys: CodingKey {
        case trailImageLight
        case trailImageDark
        case trailTitle
        case trailOwnerUserID
        case trailLikes
        case trailSubmissionTimeStamp
        case trailPublic
        case trailCoordinateLatitudes
        case trailCoordinateLongitudes
        case trailTimestamps
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(trailImageLight.pngData(), forKey: CodingKeys.trailImageLight)
        try container.encode(trailImageDark.pngData(), forKey: CodingKeys.trailImageDark)
        try container.encode(trailTitle, forKey: CodingKeys.trailTitle)
        try container.encode(trailOwnerUserID, forKey: CodingKeys.trailOwnerUserID)
        try container.encode(trailLikes, forKey: CodingKeys.trailLikes)
        try container.encode(trailSubmissionTimeStamp, forKey: CodingKeys.trailSubmissionTimeStamp)
        try container.encode(trailPublic, forKey: CodingKeys.trailPublic)
        try container.encode(trailCoordinates.map { $0.latitude }, forKey: CodingKeys.trailCoordinateLatitudes)
        try container.encode(trailCoordinates.map { $0.longitude }, forKey: CodingKeys.trailCoordinateLongitudes)
        try container.encode(trailTimestamps, forKey: CodingKeys.trailTimestamps)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trailImageLight = UIImage(data: try! container.decode(Data.self, forKey: CodingKeys.trailImageLight))!
        trailImageDark = UIImage(data: try! container.decode(Data.self, forKey: CodingKeys.trailImageDark))!
        trailTitle = (try? container.decode(String.self, forKey: CodingKeys.trailTitle)) ?? ""
        
        trailOwnerUserID = try! container.decode(Int.self, forKey: CodingKeys.trailOwnerUserID)
        trailLikes = try! container.decode(Int.self, forKey: CodingKeys.trailLikes)
        trailSubmissionTimeStamp = try! container.decode(Int.self, forKey: CodingKeys.trailSubmissionTimeStamp)
        trailPublic = try! container.decode(Bool.self, forKey: CodingKeys.trailPublic)
        
        let trailCoordinateLatitudes = try! container.decode([CLLocationDegrees].self, forKey: CodingKeys.trailCoordinateLatitudes)
        let trailCoordinateLongitudes = try! container.decode([CLLocationDegrees].self, forKey: CodingKeys.trailCoordinateLongitudes)
        
        trailCoordinates = []
        for i in 0..<trailCoordinateLongitudes.count {
            trailCoordinates.append(CLLocationCoordinate2D(latitude: trailCoordinateLatitudes[i], longitude: trailCoordinateLongitudes[i]))
        }
        
        trailTimestamps = try! container.decode([Int].self, forKey: CodingKeys.trailTimestamps)
    }
    
    // MARK: Init
    
    init() {
        
    }

}
