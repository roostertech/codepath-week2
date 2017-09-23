//
//  SwitchCell.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/21/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    @IBOutlet weak var switchToggle: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    var switchHandler: (Bool) -> Void = { (isOn: Bool) in }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSwitched(_ sender: UISwitch) {
        switchHandler(sender.isOn)
    }
    
    func prepare (with label: String) {
        switchLabel.text = label
    }
}
