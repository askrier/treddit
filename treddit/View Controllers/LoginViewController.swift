//
//  LoginViewController.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 19/4/21.
//

import AVFoundation
import UIKit

// Derived from https://www.hackingwithswift.com/example-code/media/how-to-scan-a-qr-code

class LoginViewController: UIViewController,
                           AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: Definitions
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!

    // MARK: Storyboard IB's
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backview: UIView!
    
    // MARK: View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput),
              captureSession.canAddOutput(metadataOutput) else { return }
        
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.black
        
        captureSession.addInput(videoInput)
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.view.insertSubview(view, at: 0)

        captureSession.startRunning()
        
        styleFormButton(cancelButton, accented: false)
        applyBlurEffect(to: backview)
    }
    
    func applyBlurEffect(to view: UIView) {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (!captureSession.isRunning) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }
    
    // MARK: QR Processing

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            let results = GlobalState.allPeople.filter { md5("\(Strings.salt)|\(String($0.userID))") == stringValue }
            
            if results.isEmpty {
                let alert = UIAlertController(title: "Hmmm", message: "Are you sure that's a valid code?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default) { _ in alert.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true)
                })
                present(alert, animated: true, completion: nil)
            } else {
                let user = results[0]
                let defaults = UserDefaults.standard
                defaults.setValue(String(user.userID), forKey: "LocalUserId")
                
                let alert = UIAlertController(title: "Welcome back!", message: "Good to see you \(user.username)!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in alert.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true)
                })
                
                present(alert, animated: true, completion: nil)
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
