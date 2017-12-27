//
//  ViewController.swift
//  LocationTracker
//
//  Created by 李宵逸 on 12/15/17.
//  Copyright © 2017 lxylxy123456. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var Info: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            Info.text = "init\n";
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func add_msg(_ msg: String) {
        let a = Info.text.split(separator: "\n")
        var index = a.count - 30
        if index < 0 {
            index = 0
        }
        let b = a[index...]
        var c = ""
        for i in b {
            c += i + "\n"
        }
        c += msg + "\n"
        Info.text = c
    }

    @IBAction func BeginTrack(_ sender: Any) {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    @IBAction func GetLocation(_ sender: Any) {
        locationManager.requestLocation()
    }
    func printLocation(_ prefix: String, _ manager: CLLocationManager) {
        if let loc = manager.location {
            add_msg(prefix + "\(loc.coordinate.latitude) \(loc.coordinate.longitude)")
            add_msg("  \(loc.altitude) \(loc.verticalAccuracy) \(loc.horizontalAccuracy)")
        }
        if let hdg = manager.heading {
            add_msg("  \(Float(hdg.x)) \(Float(hdg.y)) \(Float(hdg.z))")
        }
    }
    @IBAction func PrintLocation(_ sender: Any) {
        printLocation("l = ", locationManager)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        printLocation("L = ", manager)
    }
    
}

