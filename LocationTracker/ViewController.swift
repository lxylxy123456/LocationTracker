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
        var index = a.count - 10
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
        if let locationData = locationManager.location {
            let locValue = locationData.coordinate
            add_msg("l = \(locValue.latitude) \(locValue.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        add_msg("L = \(locValue.latitude) \(locValue.longitude)")
    }
    
}

