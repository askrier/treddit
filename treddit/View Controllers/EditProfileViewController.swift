//
//  EditProfileViewController.swift
//  treddit
//
//  Created by Andrew Krier on 4/13/21.
//

import UIKit
import MessageUI

class EditProfileViewController: UIViewController,
                                 UIImagePickerControllerDelegate,
                                 UINavigationControllerDelegate,
                                 MFMailComposeViewControllerDelegate {
    
    // MARK: Storyboard IB's
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var descTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet weak var topCard: UIView!
    @IBOutlet weak var bottomCard: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrCard: UIView!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var switchUsersButton: UIButton!
    
    var displayProfile: Profile = Profile.getCurrentLoggedInUser()
    
    // MARK: View Management
    
    override func viewWillAppear(_ animated: Bool) {
        displayProfile = Profile.getCurrentLoggedInUser()
        populateView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepKeyboard()
        
        topCard.layer.cornerRadius = 16
        topCard.backgroundColor = UIColor(named: "CardBackground")
        
        bottomCard.layer.cornerRadius = 16
        bottomCard.backgroundColor = UIColor(named: "CardBackground")
        
        qrCard.layer.cornerRadius = 16
        qrCard.backgroundColor = UIColor(named: "CardBackground")
        
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        styleTextField(usernameTextField)
        styleTextField(descTextField)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.pickImage(gesture:)))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.insertSubview(blurView, at: 0)
        
        populateView()
        
        styleFormButton(emailButton, accented: false)
        styleFormButton(saveButton, accented: false)
        styleFormButton(cancelButton, accented: false)
    }
    
    override func viewDidLayoutSubviews() {        
        styleFormButton(switchUsersButton, accented: true)
    }
    
    // MARK: @objc Functions
    
    @objc func save() {
        displayProfile.username = (usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty ? "anon\(String(displayProfile.userID))" : (usernameTextField.text ?? "anon\(String(displayProfile.userID))")
        displayProfile.desc = (descTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty ?"This user seems to prefer being mysterious" : (descTextField.text ?? "This user seems to prefer being mysterious")
        
        displayProfile.profPicture = profileImage.image == Profile.defaultProfilePicture ? nil : profileImage.image
        displayProfile.save()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pickImage(gesture: UIGestureRecognizer) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Remove picture", style: UIAlertAction.Style.default) { _ in
            self.profileImage.image = Profile.defaultProfilePicture
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Change picture", style: UIAlertAction.Style.default) { _ in
            let picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.delegate = self
            alert.dismiss(animated: true, completion: nil)
            
            self.present(picker, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Storyboard Cont.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        return
    }
    
    @IBAction func emailCode(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
         
        composeVC.setSubject("My Treddit Secret QR Code")
        composeVC.addAttachmentData((qrCodeImageView.image?.pngData())!, mimeType: "image/png", fileName: "secret-qr.png")
         
        present(composeVC, animated: true, completion: nil)
    }
    
}
