//
//  FullState.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 17/4/21.
//

import Foundation

class FullState: Codable {
    var allTrails: [Trail]!
    var allPeople: [Profile]!
    
    func asJSON() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}
