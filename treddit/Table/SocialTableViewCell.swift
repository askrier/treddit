//
//  TrailTableViewCell.swift
//  treddit
//
//  Created by Andrew Krier on 3/30/21.
//

import UIKit

class SocialTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var cardView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var likesButton: UIButton!
    @IBOutlet var distanceLabel: UILabel!
    
    var trail: Trail!
    var imageTappedCallback: (() -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.backgroundColor = UIColor(named: "CardBackground")
        cardView.layer.cornerRadius = 16
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        imageTappedCallback()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        let me = Profile.getCurrentLoggedInUser()
        if me.likes(trail: trail) {
            trail.trailLikes -= 1
            likesButton.setImage((UIImage(systemName: "heart")?.withTintColor(UIColor(named: "AccentColor")!))!, for: .normal)
        } else {
            trail.trailLikes += 1
            likesButton.setImage((UIImage(systemName: "heart.fill")?.withTintColor(UIColor(named: "AccentColor")!))!, for: .normal)
        }
        
        likesButton.setTitle("   \(String(trail.trailLikes))", for: .normal)
        me.toggleLike(for: trail)
    }
    

}
