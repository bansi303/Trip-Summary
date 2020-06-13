//
//  ViewController.swift
//  lab5
//
//  Created by Student on 2020-02-24.
//  Copyright © 2020 Student. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCurrentSpeed: UILabel!
    @IBOutlet weak var lblMaxSpeed: UILabel!
    @IBOutlet weak var lblAverageSpeed: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblMaxAccerlation: UILabel!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var viewLocationTrack: UIView!
    
    var locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var previousLocation:CLLocation?
    var maxSpeed:CLLocationSpeed = 0
    var sumOfSpeeds:CLLocationSpeed = 0
    var previousSpeed:CLLocationSpeed = 0
    var previousMaxAccelaration:CLLocationSpeed = 0
    var speedCounter = 0
    var totalDistance:CLLocationDistance = 0
    var exceedSpeedLimit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    @IBAction func onStartLocationBtnClicked(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        viewLocationTrack.backgroundColor = UIColor.green
    }
    
    @IBAction func onStopLocationBtnClicked(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
        viewLocationTrack.backgroundColor = UIColor.gray
        resetData()
    }
    
    func resetData(){
        viewLocationTrack.backgroundColor = UIColor.gray
        previousLocation = nil
        exceedSpeedLimit = false
        currentLocation = nil
        previousLocation = nil
        maxSpeed = 0
        sumOfSpeeds = 0
        previousSpeed = 0
        previousMaxAccelaration = 0
        speedCounter = 0
        totalDistance = 0
        exceedSpeedLimit = false
        viewAlert.backgroundColor = UIColor.white
    }
}

extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            currentLocation = location
            
            if previousLocation != nil{
                
                //----------- Calculate and set total distance ---------------------
                let distance = currentLocation?.distance(from: previousLocation!)
                totalDistance = totalDistance + distance!
                lblDistance.text = String(format: "%.2f km", (totalDistance/1000.0))
                //print("\(totalDistance/1000.0)")
                //------------------------------------------------------------------
                
                zoomToUserLocation(location: location)
                
                //----------- Set current speed & view color ----------------------
                let currentSpeed = manager.location?.speed
                lblCurrentSpeed.text = String(format: "%.2f km/h", (currentSpeed! * (3600/1000)))
                
                if (currentSpeed! * (3600/1000)) > 115{
                    viewAlert.backgroundColor = UIColor.red
                    if !exceedSpeedLimit{
                        exceedSpeedLimit = true
                        let formatedString = String.init(format: "Distance travel before exceeding the speed limit: %.2f km", totalDistance/1000.0)
                        print(formatedString)
                    }
                }
                else{
                    viewAlert.backgroundColor = UIColor.clear
                }
                //------------------------------------------------------------------
                
                //------------------ Set max & average speed -----------------------
                if let speed = currentSpeed{
                    if maxSpeed < currentSpeed!{
                        maxSpeed = currentSpeed!
                        lblMaxSpeed.text = String(format: "%.2f km/h", (maxSpeed * (3600/1000)))
                    }
                    speedCounter = speedCounter + 1
                    sumOfSpeeds = sumOfSpeeds + speed
                    
                    lblAverageSpeed.text = String(format: "%.2f km/h", (sumOfSpeeds / Double(speedCounter)) * (3600/1000))
                }
                //------------------------------------------------------------------
                
                let currentAcceleration = abs(manager.location!.speed - previousSpeed)
                
                if currentAcceleration > previousMaxAccelaration{
                    previousMaxAccelaration = currentAcceleration
                    lblMaxAccerlation.text = String(format: "%.2f m/s^2", currentAcceleration)
                }
                previousSpeed = manager.location!.speed
            }
            previousLocation = currentLocation
        }
    }
    
    func zoomToUserLocation(location:CLLocation){
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
}

