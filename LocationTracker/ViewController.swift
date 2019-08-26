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

class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    @IBOutlet weak var Info: UITextView!
    @IBOutlet weak var Interval_indicator: UILabel!
    @IBOutlet weak var Interval: UIStepper!
    @IBOutlet weak var S1: UISlider!
    @IBOutlet weak var S2: UISlider!
    @IBOutlet weak var S3: UISlider!
    @IBOutlet weak var gps_lo: UILabel!
    @IBOutlet weak var gps_la: UILabel!
    @IBOutlet weak var gps_al: UILabel!
    @IBOutlet weak var gps_he: UILabel!
    @IBOutlet weak var gps_ac: UILabel!
    @IBOutlet weak var gps_aa: UILabel!
    @IBOutlet weak var gps_sp: UILabel!
    @IBOutlet weak var gps_sp_kts: UILabel!
    @IBOutlet weak var gps_sp_mph: UILabel!
    @IBOutlet weak var gps_sp_kmph: UILabel!
    @IBOutlet weak var gps_lo_ori: UILabel!
    @IBOutlet weak var gps_la_ori: UILabel!
    @IBOutlet weak var gps_al_ori: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestAlwaysAuthorization()
        Info.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            Info.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    /*
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
    */
    @objc func update() {
        printLocation("U = ", locationManager)
    }

    @IBAction func BeginTrack(_ sender: Any) {
        locationManager.startUpdatingLocation()
        // locationManager.startUpdatingHeading()
        // motionManager.startDeviceMotionUpdates()
        // motionManager.startAccelerometerUpdates()
        let interval = Interval.value
        if timer != nil {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    @IBAction func ClearInfo(_ sender: Any) {
        UIPasteboard.general.string = Info.text
        Info.text = ""
    }
    
    func printLocation(_ prefix: String, _ manager: CLLocationManager) {
        func log_data(_ name: String, _ txt_label: UILabel, _ value: Double, _ suffix: String = "") -> String {
            var disp: String
            var str: String
            if name == "sp" {
                if value < 0 {
                    str = "null"
                    disp = "null"
                }
                else {
                    str = "\(value)"
                    disp = String(format: "%.1f", value)
                }
            }
            else if name == "he" {
                if value < 0 {
                    str = "null"
                    disp = "null"
                }
                else {
                    str = "\(value)"
                    disp = String(format: "%.1f", value)
                }
            }
            else if name == "AL" {
                str = "\(value)"
                disp = String(format: "%.1f", value)
            }
            else if name == "LA" || name == "LO" {
                str = "\(value)"
                var sgn: String
                var pos_value: Double
                if (value < 0) {
                    sgn = "-"
                    pos_value = -value
                } else {
                    sgn = ""
                    pos_value = value
                }
                let deg = Int(pos_value)
                pos_value -= Double(deg)
                pos_value *= 60.0
                let min = Int(pos_value)
                pos_value -= Double(min)
                pos_value *= 60.0
                let sec = Int(pos_value)
                pos_value -= Double(sec)
                disp = sgn + String(format: "%02d°%02d'%02d''", deg, min, sec)
                let point = String(format: "%f", pos_value)
                if let point_index = point.index(of: ".") {
                    disp += point[point_index..<point.endIndex]
                }
            }
            else {
                str = "\(value)"
                disp = "\(value)"
            }
            txt_label.text = disp + suffix
            return ",\(name):\(str)"
        }
        func assign_value(_ set: Int, _ a: Double, _ b: Double, _ c: Double) {
            let A: UISlider = S1
            let B: UISlider = S2
            let C: UISlider = S3
            A.value = Float(a)
            B.value = Float(b)
            C.value = Float(c)
        }
        if let loc = manager.location {
            // add_msg(prefix + "\(loc.coordinate.latitude) \(loc.coordinate.longitude)")
            // add_msg("  \(loc.altitude) \(loc.verticalAccuracy) \(loc.horizontalAccuracy)")
            // add_msg("  \(loc.speed) \(loc.course)")
            var log_line = "t:\(Int(Date().timeIntervalSince1970 * 1000))"
            log_line += log_data("la", gps_la_ori,  loc.coordinate.latitude)
            log_line += log_data("lo", gps_lo_ori,  loc.coordinate.longitude)
            log_line += log_data("al", gps_al,      loc.altitude)
            log_line += log_data("ac", gps_ac,      loc.horizontalAccuracy)
            log_line += log_data("aa", gps_aa,      loc.verticalAccuracy)
            log_line += log_data("he", gps_he,      loc.course,             " deg")
            log_line += log_data("sp", gps_sp,      loc.speed,              " m/s")
            _         = log_data("sp", gps_sp_kts,  loc.speed * 1.94384449, " kts")
            _         = log_data("sp", gps_sp_mph,  loc.speed * 2.23693629, " mph")
            _         = log_data("sp", gps_sp_kmph, loc.speed * 3.6,        " km/h")
            _         = log_data("LA", gps_la,      loc.coordinate.latitude)
            _         = log_data("LO", gps_lo,      loc.coordinate.longitude)
            _         = log_data("AL", gps_al_ori,  loc.altitude / 0.3048,  " ft")
            log_line += "\n"
            Info.text! = Info.text! + log_line
            let file_name = "\(Int(Date().timeIntervalSince1970 / 1000)).txt"
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(file_name)
            if let outputStream = OutputStream(url: fileURL, append: true) {
                outputStream.open()
                let bytesWritten = outputStream.write(log_line, maxLength: log_line.count)
                if bytesWritten < 0 {
                    Info.text! = Info.text! + "WRITE FAILED 1!\n"
                }
                outputStream.close()
            } else {
                Info.text! = Info.text! + "WRITE FAILED 2!\n"
            }
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
            assign_value(0, dm.attitude.pitch / Double.pi, dm.attitude.roll / Double.pi, dm.attitude.yaw / Double.pi)
            // assign_value(1, dm.rotationRate.x, dm.rotationRate.y, dm.rotationRate.z)
            /*
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
            */
        }
        // add_msg(" ")
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
    @IBAction func StopTimer(_ sender: Any) {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }
    @IBAction func Attitude_switched(_ sender: UISwitch) {
        if sender.isOn {
            motionManager.startDeviceMotionUpdates()
        }
        else {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    @IBAction func Interval_changed(_ sender: UIStepper) {
        Interval_indicator.text = String(format: "%.1f", sender.value)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // printLocation("L = ", manager)
    }
    
}

