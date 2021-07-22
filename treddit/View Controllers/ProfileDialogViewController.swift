//
//  ProfileDialogViewController.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 13/4/21.
//

import UIKit

class ProfileDialogViewController: UIViewController {

    // MARK: Storyboard IB's
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var trailsButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    private var customTransitioningDelegate = TransitioningDelegate()
    var user: Profile!
    weak var ownerVC: SocialViewController!
    
    // MARK: Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    // MARK: View Management
    
    override func viewDidLoad() {
        profileImageView.image = user.profPicture ?? Profile.defaultProfilePicture
        nameLabel.text = user.username
        descriptionLabel.text = user.desc
    }
    
    override func viewDidLayoutSubviews() {
        styleFormButton(okButton, accented: false, widthMultiplier: 1)
        styleFormButton(trailsButton, accented: true, widthMultiplier: 1)
    }
    
    // MARK: Button Functions
    
    @IBAction func okButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trailsButtonPressed(_ sender: Any) {
        if let ownerVC = ownerVC {
            ownerVC.searchQuery = "@\(user.username)"
            ownerVC.processSearchQuery()
        }

        dismiss(animated: true, completion: nil)
    }

}

// MARK: Conformity Helpers

// Source: https://stackoverflow.com/a/54738387/2672265

private extension ProfileDialogViewController {
    func configure() {
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = customTransitioningDelegate
    }
}

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class PresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = presentingViewController.view.bounds
        let size = CGSize(width: UIScreen.main.bounds.width * 0.75, height: 448)
        let origin = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
        return CGRect(origin: origin, size: size)
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        presentedView?.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin,
            .flexibleRightMargin
        ]

        presentedView?.translatesAutoresizingMaskIntoConstraints = true
        presentedView?.layer.cornerRadius = 10
    }
    
    let dimmingView: UIView = {
        let dimmingView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        return dimmingView
    }()

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        let superview = presentingViewController.view!
        superview.addSubview(dimmingView)
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            dimmingView.topAnchor.constraint(equalTo: superview.topAnchor)
        ])

        dimmingView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}
