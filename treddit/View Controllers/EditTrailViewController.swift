//
//  EditTrailViewController.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 10/4/21.
//

import UIKit

class EditTrailViewController: UIViewController {

    var trail: Trail!
    
    // MARK: Storyboard IB's
    
    @IBOutlet weak var trailImageView: UIImageView!
    @IBOutlet weak var trailNameTextField: UITextField!
    @IBOutlet weak var topCard: UIView!
    @IBOutlet weak var bottomCard: UIView!
    @IBOutlet weak var saveTrailButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var privateTrailSwitch: UISwitch!
    
    // MARK: View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepKeyboard()
        
        let chromeEffect = UIBlurEffect(style: .systemChromeMaterial)
        let chromeView = UIVisualEffectView(effect: chromeEffect)
        chromeView.frame = view.bounds
        view.insertSubview(chromeView, at: 0)
        
        trailImageView.image = traitCollection.userInterfaceStyle == .dark ? trail.trailImageDark : trail.trailImageLight
        
        topCard.backgroundColor = UIColor(named: "CardBackground")
        topCard.layer.cornerRadius = 16
        
        bottomCard.backgroundColor = UIColor(named: "CardBackground")
        bottomCard.layer.cornerRadius = 16
        
        styleTextField(trailNameTextField)
        
        trailNameTextField.text = trail.trailTitle
        privateTrailSwitch.isOn = !trail.trailPublic
    }
    
    override func viewDidLayoutSubviews() {
        
        styleFormButton(saveTrailButton, accented: true)
        styleFormButton(cancelButton, accented: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        trailImageView.image = traitCollection.userInterfaceStyle == .dark ? trail.trailImageDark : trail.trailImageLight
    }
    
    // MARK: Button Functions
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if trailNameTextField.hasText,
           !trailNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            trail.trailTitle = trailNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        
        trail.trailPublic = !privateTrailSwitch.isOn
        
        trail.save()
        
        GlobalState.trailTableViews.forEach { $0.reloadTable() }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
