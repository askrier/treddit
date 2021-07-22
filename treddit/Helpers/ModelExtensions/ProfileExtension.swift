//
//  ProfileExtension.swift
//  treddit
//
//  Created by Andrew Krier on 4/22/21.
//

import UIKit

extension Profile {
    
    static var defaultProfilePicture = (UIImage(systemName: "person.crop.circle.fill")?.withTintColor(UIColor(named: "AccentColor")!))!
    
    // MARK: Likes
    
    func toggleLike(for trail: Trail) {
        if likedTrails.contains(trail.trailId) {
            likedTrails.removeAll { $0 == trail.trailId}
        } else {
            likedTrails.append(trail.trailId)
        }
        
        save()
    }
    
    func likes(trail: Trail) -> Bool {
        return likedTrails.contains(trail.trailId)
    }
    
    // MARK: Get User
    
    static func getCurrentLoggedInUser() -> Profile {
        let defaults = UserDefaults.standard
        let localUserId = Int(defaults.string(forKey: "LocalUserId")!)!
        
        return getUserByID(localUserId)!
    }
    
    static func getUserByName(_ username: String) -> Profile? {
        let results = GlobalState.allPeople.filter { $0.username == username }
        
        return results.count > 0 ? results[0] : nil
    }
    
    static func getUserByID(_ userID: Int) -> Profile? {
        let results = GlobalState.allPeople.filter { $0.userID == userID }
        
        return results.count > 0 ? results[0] : nil
    }
    
    // MARK: JSON Storage
    
    static func loadAllProfiles() {
        let profilesFilepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("profiles")
        
        
        let jsonDecoder = JSONDecoder()
        if let data = try? Data.init(contentsOf: profilesFilepath) {
            if let allPeople = try? jsonDecoder.decode([Profile].self, from: data) {
                GlobalState.allPeople = allPeople
            }
        }
    }
    
    func save() {
        if Profile.getUserByID(self.userID) == nil {
            GlobalState.allPeople.append(self)
        }
        
        GlobalState.save()
    }
    
    static func saveAllProfilesToDisk() {
        let profilesFilepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("profiles")

        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(GlobalState.allPeople) {
            try? data.write(to: profilesFilepath)
        }
    }
    
}
