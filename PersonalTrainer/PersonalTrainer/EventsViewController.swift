//
//  EventsViewController.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 12/03/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit
import EventKit

class EventsViewController: UIViewController {
    
    //Connect Outlets
    @IBOutlet weak var reminderText: UITextField!
    
    @IBOutlet weak var myDatePicker: UIDatePicker!
    
    
    //Reference the app delegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reminderText.endEditing(true)
    }
    //Request permission to access the Users' Reminder application to add events
    @IBAction func setReminder(_ sender: Any) {
        
        if appDelegate.eventStore == nil{
            appDelegate.eventStore = EKEventStore()
            
            appDelegate.eventStore?.requestAccess(to: EKEntityType.reminder, completion: { (granted, error) in
                if !granted {
                    print ("Access to store not granted \(error!.localizedDescription)")
                }else{
                    print ("Access granted")
                }
            })
            
        }
        
        self.createReminder()
        
        
        
        //If there's no error in allowing the application to write to the Reminder, it will initiate create reminder
//        if (appDelegate.eventStore != nil){
//            self.createReminder()
//        }
    }
    
    //function to create Reminder
    func createReminder(){
        
        //class that represents the reminder added to the calendar
        let reminder = EKReminder(eventStore: appDelegate.eventStore!)
        
        //Value inputted by user are saved into the reminders
        
        reminder.title = reminderText.text!
        reminder.calendar = appDelegate.eventStore!.defaultCalendarForNewReminders()
        let date = myDatePicker.date
        let alarm = EKAlarm(absoluteDate: date)
        
        reminder.addAlarm(alarm)
        
        do{
            try appDelegate.eventStore?.save(reminder, commit: true)
            print("Reminder Saved")
        }catch let error{
            print("Reminder failed with error \(error.localizedDescription)")
        }
        
        
    }
    
    
    
    

    


}
