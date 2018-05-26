//
//  WorkoutTableViewCell.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 11/02/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit


class WorkoutTableViewCell: UITableViewCell {
    
    //Table View Cell which contains the Label and Image View for the Json Data
    
    @IBOutlet weak var workoutImg: UIImageView!
    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var workoutDesc: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
