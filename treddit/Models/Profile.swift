//
//  Profile.swift
//  treddit
//
//  Created by Andrew Krier on 3/29/21.
//

import UIKit

class Profile: NSObject, Codable {
    
    // MARK: Definition
    
    var username : String = ""
    var userID : Int = 0
    var desc : String = ""
    var profPicture: UIImage? = nil
    var likedTrails: [String] = []
    
    override init() {
        super.init()
    }

    // MARK: Codability
    
    enum CodingKeys: CodingKey {
        case username
        case userID
        case desc
        case profPicture
        case likedTrails
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: CodingKeys.username)
        try container.encode(userID, forKey: CodingKeys.userID)
        try container.encode(desc, forKey: CodingKeys.desc)
        try container.encode(profPicture?.pngData(), forKey: CodingKeys.profPicture)
        try container.encode(likedTrails, forKey: CodingKeys.likedTrails)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = (try? container.decode(String.self, forKey: CodingKeys.username)) ?? ""
        userID = (try? container.decode(Int.self, forKey: CodingKeys.userID)) ?? 0
        desc = (try? container.decode(String.self, forKey: CodingKeys.desc)) ?? ""
        profPicture = UIImage(data: (try? container.decode(Data.self, forKey: CodingKeys.profPicture)) ?? Data())
        likedTrails = (try? container.decode([String].self, forKey: CodingKeys.likedTrails)) ?? []
    }
    
    // MARK: Init
    
    init(_ username : String, uID : Int, description : String, profPicture : UIImage?) {
        super.init()
        self.username = username
        userID = uID
        desc = description
        self.profPicture = profPicture
    }
}
