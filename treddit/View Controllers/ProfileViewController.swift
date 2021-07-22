//
//  ProfileViewController.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 28/3/21.
//

import UIKit

class ProfileViewController: UIViewController,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             TrailDisplayer {

    // MARK: Definitions
    
    weak var mainController: MainTabBarViewController!

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var usernameBox: UILabel!
    @IBOutlet var descriptionBox: UILabel!
    @IBOutlet var profileTable: SocialTableView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet var editProfileButton: UIButton!
    
    var selectedTrail: Trail!
    
    var backgroundImageView: UIImageView!
    
    var featuredProfile: Profile!
    let refreshControl = UIRefreshControl()
    
    var profileTrails: [Trail] = []
    var noResults: Bool { profileTrails.count == 0 }
    
    // MARK: View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepKeyboard()
        GlobalState.trailTableViews.append(self)
        setBlurredMapBackground(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        featuredProfile = Profile.getCurrentLoggedInUser()
        profileTrails = GlobalState.allTrails.filter { $0.trailOwnerUserID == Profile.getCurrentLoggedInUser().userID
        } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
        profileImage.image = featuredProfile.profPicture ?? Profile.defaultProfilePicture
        usernameBox.text = featuredProfile.username
        descriptionBox.text = featuredProfile.desc
        profileImage.layer.cornerRadius = 50
        profileTable.dataSource = self
        profileTable.delegate = self
        profileTable.backgroundColor = .clear
        profileTable.refreshControl = refreshControl
        styleTextField(searchBar, true)
        searchBar.addTarget(self, action: #selector(searchQueryChanged), for: .editingChanged)
        searchBar.clearButtonMode = .always
        
        editProfileButton.addTarget(self, action: #selector(segueToProfileEditor), for: .touchUpInside)
        styleFormButton(editProfileButton, accented: false)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        reloadTable()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBlurredMapBackground(false)
        profileTable.reloadData()
    }
    
    // MARK: Segues
    
    @IBAction func returnFromTrail(segue: UIStoryboardSegue) {}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewTrail",
           let destination = segue.destination as? TrailViewController {
            destination.currentTrail = selectedTrail
        }
    }

}
