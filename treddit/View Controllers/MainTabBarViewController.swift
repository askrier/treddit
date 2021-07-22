//
//  MainTabBarViewController.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 28/3/21.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    var blurView: UIVisualEffectView!
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == (self.tabBar.items!)[0]{
            blurView.effect = UIBlurEffect(style: .regular)
        } else {
            blurView.effect = UIBlurEffect(style: .systemChromeMaterial)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepKeyboard()
        
        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.barTintColor = .clear
        tabBar.backgroundColor = .white
        tabBar.layer.backgroundColor = UIColor.clear.cgColor
        
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.frame = CGRect(x: tabBar.bounds.minX + 15.0, y: tabBar.bounds.minY, width: view.frame.width - 30.0, height: tabBar.bounds.height)
        
        blurView.layer.cornerRadius = tabBar.bounds.height / 2.0
        blurView.clipsToBounds = true
        tabBar.insertSubview(blurView, at: 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        blurView.frame = CGRect(x: blurView.frame.minX, y: blurView.frame.minY, width: size.width - 30.0, height: blurView.frame.height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
