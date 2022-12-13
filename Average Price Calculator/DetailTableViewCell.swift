//
//  detailTableViewCell.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 23.11.2022.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameCellLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    
    @IBOutlet weak var quantityCellLabel: UILabel!
    
    @IBOutlet weak var priceCellLabel: UILabel!
    
    @IBOutlet weak var totalCostCellLabel: UILabel!
    
    @IBOutlet weak var dateCellLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
