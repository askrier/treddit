//
//  MiscUtils.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 10/4/21.
//

import UIKit
import CryptoKit

func md5(_ source: String) -> String {
    return Insecure.MD5.hash(data: source.data(using: .utf8) ?? Data()).map {
        String(format: "%02hhx", $0)
    }.joined()
}

func styleTextField(_ textField: UITextField, _ solidBackground: Bool = false) {
    textField.layer.cornerRadius = 17.0
    textField.clipsToBounds = true
    
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.size.height))
    textField.leftView = paddingView
    textField.leftViewMode = .always
    
    textField.textColor = UIColor(named: "MainTextColor")
    textField.font = UIFont(name: "Avenir-Light", size: 14)
    
    var view: UIView!
    if solidBackground {
        view = UIView()
        view.backgroundColor = UIColor.init(named: "CardBackground")
    } else {
        let chromeEffect = UIBlurEffect(style: .systemChromeMaterial)
        view = UIVisualEffectView(effect: chromeEffect)
    }
    
    
    view.frame = textField.bounds
    view.isUserInteractionEnabled = false
    
    textField.insertSubview(view, at: 0)
}

func styleFormButton(_ button: UIButton, accented: Bool, widthMultiplier: CGFloat = 1.0) {
    
    let view = UIView()
    view.frame = CGRect(x: button.bounds.minX - 10.0, y: button.bounds.minY - 10.0, width: button.bounds.width * widthMultiplier + 20.0, height: button.bounds.height + 20.0)
    view.layer.cornerRadius = (button.bounds.height + 20) / 2.0
    view.layer.zPosition = -1
    view.isUserInteractionEnabled = false
    view.clipsToBounds = true
    
    if accented {
        view.backgroundColor = UIColor(named: "AccentColor")
        button.setTitleColor(.white, for: .normal)
    } else {
        view.backgroundColor = UIColor(named: "CardBackground")
        button.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
    }
    
    button.addSubview(view)
    
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowRadius = 5.0
    button.layer.shadowOpacity = 0.1
    button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    button.layer.masksToBounds = false
}
