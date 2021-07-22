//
//  SocialVCExtension.swift
//  treddit
//
//  Created by Andrew Krier on 4/22/21.
//

import UIKit
import MapKit

extension SocialViewController {
    
    func reloadTable() {
        socialTrails = GlobalState.allTrails.filter { $0.trailPublic } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
        socialTable.reloadData()
    }
    
    // MARK: @objc Functions
    
    @objc func refresh(_ sender: Any) {
        GlobalState.sync {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func searchQueryChanged() {
        searchQuery = searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery.isEmpty {
            socialTrails = GlobalState.allTrails.filter { $0.trailPublic } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
            searching = false
            socialTable.reloadData()
        } else {
            
            processSearchQuery()
        }
    }
    
    func processSearchQuery() {
        if searchBar.text != searchQuery { // We were called by profile card UI
            searchBar.text = searchQuery
        }
        
        if searchQuery.starts(with: "@") {
            let username = searchQuery.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet.init(charactersIn: "@")))
            let user = Profile.getUserByName(username)
            socialTrails = GlobalState.allTrails.filter { $0.trailOwnerUserID == user?.userID ?? -1 && $0.trailPublic } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
        } else {
            socialTrails = GlobalState.allTrails.filter { $0.trailTitle.lowercased().contains(searchQuery) && $0.trailPublic } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
        }
        
        searching = true
        socialTable.reloadData()
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
        return socialTrails.count > 0 ? socialTrails.count : 1
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "socialTableCell", for: indexPath) as! SocialTableViewCell
        
        let trail = socialTrails[indexPath.row]
        
        let trailOwner = Profile.getUserByID(trail.trailOwnerUserID)!
        
        cell.nameLabel.text = trailOwner.username
        let date = Date(timeIntervalSince1970: (Double(trail.trailSubmissionTimeStamp!) / 1000.0))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        cell.titleLabel.text = "\(formatter.string(from: date))\(!trail.trailTitle.isEmpty ? " · " : "")\(trail.trailTitle)"
        cell.profileImageView.image = trailOwner.profPicture ?? Profile.defaultProfilePicture
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
            (controller as! ProfileDialogViewController).user = trailOwner
            (controller as! ProfileDialogViewController).ownerVC = self
            self.present(controller, animated: true)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if noResults { return }
        
        selectedTrail = socialTrails[indexPath.row]
        performSegue(withIdentifier: "viewTrail", sender: self)
    }
    
}
