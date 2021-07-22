//
//  ProfileVCExtension.swift
//  treddit
//
//  Created by Andrew Krier on 4/22/21.
//

import UIKit

extension ProfileViewController {
    
    func reloadTable() {
        profileTrails = GlobalState.allTrails.filter { $0.trailOwnerUserID == Profile.getCurrentLoggedInUser().userID
        } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
        profileTable.reloadData()
    }
    
    // MARK: @objc Functions
    
    @objc func refresh(_ sender: Any) {
        GlobalState.sync {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func segueToProfileEditor() {
        performSegue(withIdentifier: "toEditProfile", sender: self)
    }
    
    @objc func searchQueryChanged() {
        if searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            profileTrails = GlobalState.allTrails.filter { $0.trailOwnerUserID == Profile.getCurrentLoggedInUser().userID
            } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
        } else {
            let q = searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            profileTrails = GlobalState.allTrails.filter { $0.trailTitle.lowercased().contains(q) }
        }
        
        profileTable.reloadData()
    }
    
    // MARK: Blur
    
    func setBlurredMapBackground(_ firstTime: Bool) {
        let filename = traitCollection.userInterfaceStyle == .dark
            ? Strings.backgroundFilenameDark : Strings.backgroundFilenameLight
        
        let backgroundImage = loadImage(fromFile: filename)
        if firstTime {
            backgroundImageView = UIImageView.init(frame: view.frame)
        }

        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill

        if firstTime {
            view.insertSubview(backgroundImageView, at: 0)
            applyBlurEffect(to: backgroundImageView)
        }
    }
    
    func applyBlurEffect(to view: UIView) {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }
    
    // MARK: Table Management
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileTrails.count > 0 ? profileTrails.count : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nothingFoundCell", for: indexPath) as! EmptyTableViewCell
            
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = profileTable.dequeueReusableCell(withIdentifier: "socialTableCell", for: indexPath) as! SocialTableViewCell
        
        let trail = profileTrails[indexPath.row]
        
        cell.nameLabel.text = featuredProfile.username
        let date = Date(timeIntervalSince1970: (Double(trail.trailSubmissionTimeStamp!) / 1000.0))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        cell.titleLabel.text = "\(formatter.string(from: date))\(!trail.trailTitle.isEmpty ? " · " : "")\(trail.trailTitle)"
        cell.profileImageView.image = featuredProfile.profPicture ?? Profile.defaultProfilePicture
        cell.profileImageView.layer.cornerRadius = 25
        cell.likesButton.setTitle("  \(String(trail.trailLikes))", for: .normal)
        cell.mapImageView.image = traitCollection.userInterfaceStyle == .dark ? trail.trailImageDark : trail.trailImageLight
        let dist = Double(round(10*trail.distanceFromMiles(GlobalState.currLocation))/10)
        cell.distanceLabel.text = "\(dist) mi away"
        
        if Profile.getCurrentLoggedInUser().likes(trail: trail) {
            cell.likesButton.setImage((UIImage(systemName: "heart.fill")?.withTintColor(UIColor(named: "AccentColor")!))!, for: .normal)
        } else {
            cell.likesButton.setImage((UIImage(systemName: "heart")?.withTintColor(UIColor(named: "AccentColor")!))!, for: .normal)
        }
        
        cell.selectionStyle = .none
        cell.trail = trail
        cell.imageTappedCallback = {
            () in
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "ProfileDialog")
            (controller as! ProfileDialogViewController).user = self.featuredProfile
            (controller as! ProfileDialogViewController).ownerVC = nil
            self.present(controller, animated: true)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if noResults { return }
        
        selectedTrail = profileTrails[indexPath.row]
        performSegue(withIdentifier: "viewTrail", sender: self)
    
    }
    
}
