//
//  ExerciseViewController.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 11/02/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit

class ExerciseViewController: UIViewController {
    
    //Created Label and Image View
    
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var exerciseImage: UIImageView!
    @IBOutlet weak var exerciseDescription: UILabel!
    
    //Created a variable called selectedExercise for when a user selects an item from the Table View
    var selectedExercise:Tutorials?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gets data from the selected item from the Tabel view containing Name, Description and Image of exercise
        exerciseName.text = selectedExercise?.name
        exerciseImage.downloadImage(from: (selectedExercise?.imgURL)!)
        exerciseDescription.text = selectedExercise?.desc

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
