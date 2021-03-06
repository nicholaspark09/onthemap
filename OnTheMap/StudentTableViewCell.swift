//
//  StudentTableViewCell.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit

class StudentTableViewCell: UITableViewCell {

    var student: StudentInformation?{
        didSet{
            studentLabel?.text = "\(student!.firstName) \(student!.lastName)"
            dateLabel?.text = "\(student!.updatedAt)"
        }
    }
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var studentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
