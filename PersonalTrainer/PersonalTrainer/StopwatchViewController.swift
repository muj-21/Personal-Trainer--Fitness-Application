//
//  StopwatchViewController.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 11/02/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit

class StopwatchViewController: UIViewController{
    

    //Connected outlets to View Controller
    @IBOutlet weak var timeLabl: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!

    //Starts the timer
    
    @IBAction func startTimer(_ sender: Any) {
        if(isPlaying){
            return
        }
        startButton.isEnabled = false
        pauseButton.isEnabled = true
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true

    }
    
    //Pause the timer
    @IBAction func pauseTimer(_ sender: Any) {
        startButton.isEnabled = true
        pauseButton.isEnabled = false
        
        timer.invalidate()
        isPlaying = false
        
    }
    
    //Resets the timer
    @IBAction func resetTimer(_ sender: Any) {
        startButton.isEnabled = true
        pauseButton.isEnabled = false
        
        timer.invalidate()
        isPlaying = false
        counter = 0.0
        timeLabl.text = String(counter)
    }
    //Updates timer
    @objc func UpdateTimer(){
        counter = counter + 0.1
        timeLabl.text = String(format: "%.1f", counter)
    }
    //Created variable counter which starts with 0.0
    var counter = 0.0
    
    //Created a variable timer which initiates the timer
    var timer = Timer()
    
    
    var isPlaying = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timeLabl.text = String(counter)
        pauseButton.isEnabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
