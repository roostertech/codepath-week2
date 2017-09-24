//
//  SelectionCell.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/23/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {

    @IBOutlet weak var selectionText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func prepare (selectionLabel: String, isSelected: Bool) {
        self.selectionText.text = selectionLabel
        accessoryType = isSelected ? .checkmark : .none
    }
}
