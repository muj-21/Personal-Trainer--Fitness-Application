//
//  ProfileBMIViewController.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 19/02/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit
import HealthKit
//Access point for all data managed by Health Kit
let healthKitStore:HKHealthStore = HKHealthStore()

class ProfileBMIViewController: UIViewController {
    //Connect outlets
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var bloodTypeLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    
    
    @IBOutlet weak var weightText: UITextField!
    
    @IBOutlet weak var heightText: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   

    
    @IBAction func authorizeClicked(_ sender: Any) {
        self.authorizeHealthKitinApp()
    }
    //Once user selects get details button, it retrieves the data that has been passed and assigns to its outlet
    @IBAction func getDetails(_ sender: UIButton) {
        let (age, bloodtype, sex) = self.readProfile()
        self.ageLabel.text = "\(String(describing: age!))"
        self.bloodTypeLabel.text = self.getReadableBloodType(bloodType: bloodtype?.bloodType)
        self.sexLabel.text = self.getReadableSex(sex: sex?.biologicalSex)
        self.readMostRecentSample()
        self.readHeight()
        
    }
    //convert the data passed into readable string
    func getReadableBloodType(bloodType:HKBloodType?) -> String{
        var bloodTypeText = "";
        if bloodType != nil{
            switch ( bloodType! ) {
            case .aPositive:
                bloodTypeText = "A+"
            case .aNegative:
                bloodTypeText = "A-"
            case .bPositive:
                bloodTypeText = "B+"
            case .bNegative:
                bloodTypeText = "B-"
            case .abPositive:
                bloodTypeText = "AB+"
            case .abNegative:
                bloodTypeText = "AB-"
            case .oPositive:
                bloodTypeText = "O+"
            case .oNegative:
                bloodTypeText = "O-"
            default:
                break;
            }
        }
        return bloodTypeText;
    }
    //Convert the data passed into readable String
    func getReadableSex(sex:HKBiologicalSex?) -> String{
        var sexTypeText = "";
        if sex != nil{
            switch ( sex! ) {
            case .male:
                sexTypeText = "Male"
            case .female:
                sexTypeText = "Female"
            case .other:
                sexTypeText = "Other"
            case .notSet:
                sexTypeText = "Not Set"
            default:
                break;
            }
        }
        return sexTypeText;
    }


    func readProfile() -> (age:Int?, bloodtype:HKBloodTypeObject?, sex:HKBiologicalSexObject?){
        
        var age:Int?
        var sex:HKBiologicalSexObject?
        var bloodType:HKBloodTypeObject?
        
        //read age
        do{
            let birthDay = try healthKitStore.dateOfBirthComponents()
            let calender = Calendar.current
            let currentyear = calender.component(.year, from: Date())
            age = currentyear - birthDay.year!
        } catch{}
        
        //bloodtye
        do{
            bloodType = try healthKitStore.bloodType()
        }catch{}
        //sex
        do{
            sex = try healthKitStore.biologicalSex()
        }catch{}
        
        
        return (age, bloodType, sex)
        

    }
    
    
    
    

    //Permission to read and write data from HealthKit

    func authorizeHealthKitinApp() {
        let healthKitTypesToRead : Set<HKObjectType> = [HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!, HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!, HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.bloodType)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!]
        
        let healthKitTypesToWrite : Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!]
        
        //Prints error if Data is not available
        
        if !HKHealthStore.isHealthDataAvailable(){
            print("Error occured")
            return
        }
        
        //Prints success if Data is available
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            print("Read Write Authorization succeeded")
        }
    }
    
    @IBAction func writeDataToHealthKit(_ sender: Any) {
        self.writeToHealthKit()
        self.weightText.text = ""
        self.heightText.text = ""
    }
    //Write data to HealthKit
    
    //Write Weight
    func writeToHealthKit(){
        let weight = Double(self.weightText.text!)
        
        let today = NSDate()
        if let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass){
            
            let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: Double(weight!))
            let sample = HKQuantitySample(type: type, quantity: quantity, start: today as Date, end: today as Date)
            
            healthKitStore.save(sample, withCompletion: {(success, error) in
                print ("Saved \(success), error \(error)")
            })
        }
        
        //Write Height
        let height = Double(self.heightText.text!)
        
        if let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height) {
            
            let quantity = HKQuantity(unit: HKUnit.foot(), doubleValue: Double(height!))
            let sample = HKQuantitySample(type: type, quantity: quantity, start: today as Date, end: today as Date)
            
            healthKitStore.save(sample, withCompletion: { (success, error) in
                print("Saved \(success), error \(error)")
            })
        }
        
    }
    //Read existing weight
    func readMostRecentSample(){
        let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil){(query, results, error) in
            if let result = results?.last as? HKQuantitySample{
                print("weight => \(result.quantity)")
                DispatchQueue.main.async(execute: {() -> Void in
                    self.weightText.text = "\(result.quantity)"
                });
            }else{
                print("Ooops didn't get weight \nResults => \(String(describing: results)), error => \(String(describing: error))")
            }
        }
        healthKitStore.execute(query)

    }
    //Read existing Height
    func readHeight(){
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.last as? HKQuantitySample{
                print("Height => \(result.quantity)")
                DispatchQueue.main.async(execute: {() -> Void in
                    self.heightText.text = "\(result.quantity)"
                });
            }else{
                print("OOPS didnt get height \nResults => \(String(describing: results)), error => \(String(describing: error))")
            }
        }
        healthKitStore.execute(query)
    }

}
