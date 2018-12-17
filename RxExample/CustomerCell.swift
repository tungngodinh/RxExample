//
//  CustomerCell.swift
//  RxExample
//
//  Created by tungnd on 12/17/18.
//  Copyright © 2018 tungnd. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {

    static let cellIdenfiter = "CustomerCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
