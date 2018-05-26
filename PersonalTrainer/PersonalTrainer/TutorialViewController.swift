//
//  TutorialViewController.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 07/02/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TutorialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //Connected tableview to the Tutorial View Controller
    @IBOutlet weak var tableview: UITableView!
    
    //Create a tutorials array which will contain all the tutorials
    var tutorials: [Tutorials]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWorkouts()
    }
    
    
    //Created a function called fetchWorkouts which will retrieve the json data for tutorials
    func fetchWorkouts(){
        
        //made a URLRequest to the site which I will retrieve the json data
        let urlRequest = URLRequest(url: URL(string: "https://next.json-generator.com/api/json/get/4kIb1rYIN")!)
        
        //Gets data from the URL which will contain 3 things. The json data, a response whether it was successful or not and an error if it was unsuccessful
        let task = URLSession.shared.dataTask(with: urlRequest) {(data,response,error) in
            if error != nil {
                print(error)
                return
            }
            //After passing through error, I can now create my Tutorials object
            self.tutorials = [Tutorials]()
            do{
                
                //create object from the data recieved and cast it as String to AnyObject as the format of the json is a dictionary
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                //Retrieve the array of dictionaries which is called Workouts
                if let tutorialsFromJson = json["Workouts"] as? [[String : AnyObject]] {
                    for tutorialFromJson in tutorialsFromJson {
                        let tutorial = Tutorials()
                        //retrieve the dictionaries name, description and urlToImage
                        if let name = tutorialFromJson["name"] as? String, let description = tutorialFromJson["description"] as? String, let urlToImage = tutorialFromJson["urlToImage"] as? String{
                            tutorial.name = name
                            tutorial.desc = description
                            tutorial.imgURL = urlToImage
                            
                        }
                        //appends the empty arrya of tutorials created earlier
                        self.tutorials?.append(tutorial)
                        
                    }
                    
                }
                //Dispatches the reload of data to the main thread to speed up the reload of data
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
                
            }catch let error {
                print(error)
            }
            
        }
        task.resume()
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tutorialCell", for: indexPath) as! WorkoutTableViewCell
        
        //The tutorial objects are assigned to the Text label and ImageView displayed on the storyboard
        cell.workoutImg.downloadImage(from: (self.tutorials?[indexPath.item].imgURL!)!)
        cell.workoutName.text = self.tutorials?[indexPath.item].name
        cell.workoutDesc.text = self.tutorials?[indexPath.item].desc
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tutorials?.count ?? 0
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ExerciseViewController
        let selectedExerciseIndex = self.tableview.indexPathForSelectedRow?.row
        destVC.selectedExercise = tutorials?[selectedExerciseIndex!]
    }
    
    
}
//created a function downloadImage which takes in the url for the images in the json data and creates it into an object

    extension UIImageView{
        func downloadImage(from url: String){
            
            let urlRequest = URLRequest(url: URL(string: url)!)
            
            let task = URLSession.shared.dataTask(with: urlRequest){(data,response,error) in
                
                if error != nil{
                    print(error)
                    return
                }
                DispatchQueue.main.async {
                    //image data becomes an object
                    self.image = UIImage(data: data!)
                }
            }
            task.resume()
            
        }
}
