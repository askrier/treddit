//
//  EmptyTableViewCell.swift
//  treddit
//
//  Created by Anshu Dwibhashi on 11/4/21.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var card: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        card.layer.cornerRadius = 16
        card.backgroundColor = UIColor(named: "CardBackground")        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
