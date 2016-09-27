//
//  TableViewCell.swift
//  travelinfo
//
//  Created by Gemtek on 9/25/16.
//  Copyright © 2016 Gemtek. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet weak var cellSubtitle: UILabel!
    
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
