//
//  ViewController.swift
//  LocationTracker
//
//  Created by 李宵逸 on 12/15/17.
//  Copyright © 2017 lxylxy123456. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    var delta_acceleration: [Double] = [0, 0, 0]
    var cur_velocity: [Double] = [0, 0, 0]
    var speed_history: [[Double]] = [[], []]
    let interval = 0.2
    
    @IBOutlet weak var Info: UITextView!
    @IBOutlet weak var S1: UISlider!
    @IBOutlet weak var S2: UISlider!
    @IBOutlet weak var S3: UISlider!
    @IBOutlet weak var S4: UISlider!
    @IBOutlet weak var S5: UISlider!
    @IBOutlet weak var S6: UISlider!
    
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
    
    @objc func update() {
        printLocation("U = ", locationManager)
    }

    @IBAction func BeginTrack(_ sender: Any) {
        locationManager.startUpdatingLocation()
        // locationManager.startUpdatingHeading()
        motionManager.startDeviceMotionUpdates()
        motionManager.startAccelerometerUpdates()
        _ = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    @IBAction func ZeroSpeed(_ sender: Any) {
        cur_velocity = [0, 0, 0]
        speed_history[1] = []
    }
    func printLocation(_ prefix: String, _ manager: CLLocationManager) {
        func mean(_ values: [Double], _ end: Int) -> Double {
            var sum = 0.0
            let real_end = min(end, values.count)
            for i in 0...(real_end - 1) {
                sum += values[i]
            }
            return sum / Double(real_end)
        }
        func log_speed(_ index: Int, _ value: Double) {
            speed_history[index].insert(value, at: 0)
            if speed_history.count > Int(15.0 / interval) {
                speed_history[index].removeLast()
            }
            let m1 = String(format: "% 8.1f", mean(speed_history[index], 1) * 2.23693629)
            let m5 = String(format: "% 8.1f", mean(speed_history[index], 5) * 2.23693629)
            let m15 = String(format: "% 8.1f", mean(speed_history[index], 15) * 2.23693629)
            add_msg("\(m1)\t\(m5)\t\(m15)")
            // return [mean(speed_history[index][..<Int(1 / interval)]), mean(speed_history[index][..<Int(5 / interval)]), mean(speed_history[index][..<Int(15 / interval)])]
        }
        func assign_value(_ set: Int, _ a: Double, _ b: Double, _ c: Double) {
            var A: UISlider = S1
            var B: UISlider = S2
            var C: UISlider = S3
            if set == 1 {
                A = S4
                B = S5
                C = S6
            }
            A.value = Float(a)
            B.value = Float(b)
            C.value = Float(c)
        }
        if let loc = manager.location {
            // add_msg(prefix + "\(loc.coordinate.latitude) \(loc.coordinate.longitude)")
            // add_msg("  \(loc.altitude) \(loc.verticalAccuracy) \(loc.horizontalAccuracy)")
            // add_msg("  \(loc.speed) \(loc.course)")
            let gps_speed = loc.speed
            log_speed(0, gps_speed)
        }
        /*
        if let hdg = manager.heading {
            add_msg("  \(Float(hdg.x)) \(Float(hdg.y)) \(Float(hdg.z))")
        }
        */
        if let dm = motionManager.deviceMotion {
            // add_msg(" \(Float(dm.userAcceleration.x)) \(Float(dm.userAcceleration.y)) \(Float(dm.userAcceleration.z))")
            // add_msg(" \(Float(dm.gravity.x)) \(Float(dm.gravity.y)) \(Float(dm.gravity.z))")
            // add_msg(" \(Float(dm.attitude.roll))\t\(Float(dm.attitude.pitch))\t\(Float(dm.attitude.yaw))")
            // add_msg(" \(Float(dm.rotationRate.x))\t\(Float(dm.rotationRate.y))\t\(Float(dm.rotationRate.z))")
            // assign_value(0, dm.attitude.pitch / Double.pi, dm.attitude.roll / Double.pi, dm.attitude.yaw / Double.pi)
            // assign_value(1, dm.rotationRate.x, dm.rotationRate.y, dm.rotationRate.z)
            let r = dm.attitude.roll
            let p = dm.attitude.pitch
            let y = dm.attitude.yaw
            let vx: [Double] = [cos(r) * cos(y) - sin(r) * sin(p) * sin(y), sin(r) * sin(p) * cos(y) + cos(r) * sin(y), -sin(r) * cos(p)]
            let vy: [Double] = [-cos(p) * sin(y), cos(p) * cos(y), sin(p)]
            let vz: [Double] = [sin(r) * cos(y) + sin(p) * cos(r) * sin(y), -sin(p) * cos(r) * cos(y) + sin(r) * sin(y), cos(p) * cos(r)]
            let trimed_acceleration: [Double] = [dm.userAcceleration.x - delta_acceleration[0], dm.userAcceleration.y - delta_acceleration[1], dm.userAcceleration.z - delta_acceleration[2]]
            let gnd_acceleration: [Double] = [vx[0] * trimed_acceleration[0] + vy[0] * trimed_acceleration[1] + vz[0] * trimed_acceleration[2], vx[1] * trimed_acceleration[0] + vy[1] * trimed_acceleration[1] + vz[1] * trimed_acceleration[2], vx[2] * trimed_acceleration[0] + vy[2] * trimed_acceleration[1] + vz[2] * trimed_acceleration[2]]
            cur_velocity[0] += 9.81 * gnd_acceleration[0] * interval
            cur_velocity[1] += 9.81 * gnd_acceleration[1] * interval
            cur_velocity[2] += 9.81 * gnd_acceleration[2] * interval
            assign_value(0, cur_velocity[0], cur_velocity[1], cur_velocity[2])
            assign_value(1, gnd_acceleration[0], gnd_acceleration[1], gnd_acceleration[2])
            let inertial_speed = sqrt(cur_velocity[0]*cur_velocity[0] + cur_velocity[1]*cur_velocity[1] + cur_velocity[2]*cur_velocity[2])
            log_speed(1, inertial_speed)
        }
        add_msg(" ")
        /*
            W   S   U
            1   0   0   x
            0   1   0   y
            0   0   1   z
         After roll angle r (y axis)
            cos(r)  0   -sin(r)
            0       1   0
            sin(r)  0   cos(r)
         After pitch angle p (x axis of ground)
            cos(r)  sin(r) * sin(p)     -sin(r) * cos(p)
            0       cos(p)              sin(p)
            sin(r)  -sin(p) * cos(r)    cos(p) * cos(r)
         After yaw angle y (z axis of ground)
            cos(r) * cos(y) - sin(r) * sin(p) * sin(y)      sin(r) * sin(p) * cos(y) + cos(r) * sin(y)      -sin(r) * cos(p)
            -cos(p) * sin(y)                                cos(p) * cos(y)                                 sin(p)
            sin(r) * cos(y) + sin(p) * cos(r) * sin(y)      -sin(p) * cos(r) * cos(y) + sin(r) * sin(y)     cos(p) * cos(r)
         
         When letting (a, b) rotate angle y in x -> y -> -x -> -y direction
         r = sqrt(a**2 + b**2)
         t = atan(b / a)  when b < 0, t = atan(b / a) + pi
         t' = t + y
         a' = cos(t') * r = cos(t + y) * r
         b' = sin(t') * r = sin(t + y) * r
         sin(t) = b / r
         cos(t) = a / r
         a' = (a/r * cos(y) - b/r * sin(y)) * r = a * cos(y) - b * sin(y)
         b' = (b/r * cos(y) + a/r * sin(y)) * r = b * cos(y) + a * sin(y)
         */
    }
    @IBAction func PrintLocation(_ sender: Any) {
        printLocation("l = ", locationManager)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        printLocation("L = ", manager)
    }
    
}

