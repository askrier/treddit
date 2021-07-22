//
//  SocialViewController.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 28/3/21.
//

/*
 * https://levelup.gitconnected.com/getting-started-with-uitableview-in-swift-9b04e6fd8b9a
 */

import UIKit
import MapKit

class SocialViewController: UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            TrailDisplayer {
    
    // MARK: Definitions
    
    weak var mainController: MainTabBarViewController!
    @IBOutlet var socialTable: SocialTableView!
    @IBOutlet weak var searchBar: UITextField!
    var backgroundImageView: UIImageView!
    var searching = false
    var selectedTrail: Trail!
    let refreshControl = UIRefreshControl()
    
    var socialTrails = GlobalState.allTrails.filter { $0.trailPublic } .sorted { $0.trailSubmissionTimeStamp > $1.trailSubmissionTimeStamp }
    var noResults: Bool { socialTrails.count == 0 }
    var searchQuery = ""
    
    // MARK: View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepKeyboard()
        setBlurredMapBackground(true)
        socialTable.dataSource = self
        socialTable.delegate = self
        socialTable.refreshControl = refreshControl
        socialTable.backgroundColor = .clear
        styleTextField(searchBar, true)
        searchBar.addTarget(self, action: #selector(searchQueryChanged), for: .editingChanged)
        searchBar.clearButtonMode = .always
        GlobalState.trailTableViews.append(self)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTable()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setBlurredMapBackground(false)
        socialTable.reloadData()
    }
    
    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewTrail",
           let destination = segue.destination as? TrailViewController {
            destination.currentTrail = selectedTrail
        }
    }
    
    @IBAction func returnFromTrail(segue: UIStoryboardSegue) {}

}
