//
//  ListOfTableViewCell.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 16.12.2022.
//

import UIKit

class ListOfTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameCoinLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
