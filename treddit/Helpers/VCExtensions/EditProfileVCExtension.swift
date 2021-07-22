//
//  EditProfileVCExtension.swift
//  treddit
//
//  Created by Andrew Krier on 4/22/21.
//

import UIKit
import MessageUI

extension EditProfileViewController {
    
    // MARK: Update Methods
    
    func populateView() {
        profileImage.image = displayProfile.profPicture ?? Profile.defaultProfilePicture
        profileImage.layer.cornerRadius = 50
        
        usernameTextField.text = displayProfile.username
        descTextField.text = displayProfile.desc
        
        let secret = md5("\(Strings.salt)|\(String(displayProfile.userID))")
        generateQRCode(from: secret)
    }
    
    func setProfile(_ p : Profile) -> Void {
        displayProfile = p
    }
    
    // MARK: Email
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        if result == .sent {
            let alert = UIAlertController(title: "Email sent", message: "Keep it safe so you can recover your account!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in alert.dismiss(animated: true, completion: nil)})
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard (info[.originalImage] as? UIImage) != nil else { return }
        
        let clicked : UIImage = info[.originalImage] as! UIImage
        
        profileImage.image = clicked
        
        dismiss(animated: true)
    }
    
    // MARK: QR Code
    
    func generateQRCode(from string: String) {
            // Modified from: https://stackoverflow.com/a/48945637/2672265
            
            let data = string.data(using: String.Encoding.ascii)

            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")

                guard let qrImage = filter.outputImage else { return }
                let scaleX = self.qrCodeImageView.frame.size.width / qrImage.extent.size.width
                let scaleY = self.qrCodeImageView.frame.size.height / qrImage.extent.size.height
                let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

                if let output = filter.outputImage?.transformed(by: transform) {
                    qrCodeImageView.image = UIImage(ciImage: output)
                }
            }
        }
    
}
