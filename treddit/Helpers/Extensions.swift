//
//  Extensions.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 19/4/21.
//

import UIKit

extension UIViewController {
    func prepKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
 }
