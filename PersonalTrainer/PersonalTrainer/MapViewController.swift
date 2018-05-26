//
//  MapViewController.swift
//  PersonalTrainer
//
//  Created by Mujtaba Ahmed on 05/02/2018.
//  Copyright © 2018 Mujtaba Ahmed. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var map: MKMapView!
    //Created the variable locationManager which is equal to CLLocationManger
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //The requirements for the variable locationManager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.map.showsUserLocation = true    }
    
    
    //Created the function locationManager which will updata the locations of the map such as regions, lat and long
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        let location = location.last
        
    
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude:  location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        
        
        let request = MKLocalSearchRequest()
        
        
        request.naturalLanguageQuery = "gym"
        request.region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        MKLocalSearch(request: request).start { (response, error) in
            guard error == nil else {return}
            guard let response  = response else {return}
            guard response.mapItems.count > 0 else {return}
            
            let randomIndex = Int(arc4random_uniform(UInt32(response.mapItems.count)))
            let mapItem = response.mapItems[randomIndex]
            
            
            mapItem.openInMaps(launchOptions: nil)
            
            self.map.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
            
            
            
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
            
            print("Error: " + error.localizedDescription)
        }
        
    }


}
