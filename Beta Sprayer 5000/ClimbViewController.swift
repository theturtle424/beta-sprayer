//
//  ClimbViewController.swift
//  Beta Sprayer 5000
//
//  Created by Franklin DeHart on 7/24/16.
//  Copyright © 2016 Franklin DeHart. All rights reserved.
//


import UIKit
import CoreMotion
import AVFoundation
import RealmSwift
import Realm
import Charts
import ChartsRealm

class ClimbViewController: UIViewController {
    
    var g_motionManager = CMMotionManager()
    var g_altimeter = CMAltimeter()
    var g_altiQueue = NSOperationQueue()
    var g_accelQueue = NSOperationQueue()
    var g_motionQueue = NSOperationQueue()
    var g_audioPlayer = AVAudioPlayer()
    var g_count = 0
    var g_lastAltitudeMark = NSNumber.init(float: 0.0)
    
    var g_altitudeThresh = Float(0.5)
    var g_accelThresh = Float(2.1)
    
    var g_activityStart = NSDate()
    
    //    @IBOutlet weak var amountSlider: UISlider!
    //    @IBOutlet weak var typeSlider: UISlider!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var altitudeSlider: UISlider!
    @IBOutlet weak var altitudeThreshLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    @IBOutlet weak var accelSlider: UISlider!
    @IBOutlet weak var accelThreshLabel: UILabel!
    @IBOutlet weak var xAccel: UILabel!
    @IBOutlet weak var yAccel: UILabel!
    @IBOutlet weak var zAccel: UILabel!
    
    @IBOutlet weak var altitudeGraphView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.enabled = false
        self.altitudeThreshLabel.text = "Altitude Threshold: \(self.altitudeSlider.value) m"
        self.accelThreshLabel.text = "Acceleration Threshold: \(self.accelSlider.value) G"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playClip(soundsArr: [String]) {
        
        
        let idx = Int(arc4random_uniform(UInt32(soundsArr.count)))
        
        let alertSound = NSURL(
            fileURLWithPath: NSBundle.mainBundle().pathForResource(
                soundsArr[idx],
                ofType: "m4a")!)
        print(alertSound)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error")
            return
        }
        
        do {
            try self.g_audioPlayer = AVAudioPlayer(contentsOfURL: alertSound)
        } catch {
            print("Error")
            return
        }
        self.g_audioPlayer.prepareToPlay()
        self.g_audioPlayer.play()
    }
    
    func playLanding() {
        self.playClip([
            "awesome_dude",
            "sick_send",
            "sick_send_brah",
            ])
    }
    
    func playMotivation(){
        self.playClip([
            "cmon_keep_pushing",
            "come_on",
            "keep_breathin",
            "keep_that_core_tight",
            "nice",
            "yeah_there_it_is",
            "nice_06",
            "oh_yeah",
            "yeah_02",
            ])
    }
    
    
    @IBAction func stopPressed(sender: AnyObject) {
        if self.g_motionManager.accelerometerActive {
            self.g_motionManager.stopAccelerometerUpdates()
        }
        self.g_altimeter.stopRelativeAltitudeUpdates()
        // reset the last altitude thresh so the new updates start at 0
        self.g_lastAltitudeMark = NSNumber.init(float: 0.0)
        stopButton.enabled = false
        startButton.enabled = true
        
//        let realm  = try! Realm()
        let results = RLMRealm.defaultRealm().allObjects("AltDataPt")
        
        let set = RealmLineDataSet(results: results, yValueField: "altitude", label: "altitunde")
        var dataSets = [set]
        
        let data = RealmLineData(results: results, xValueField: "time", dataSets: dataSets)
        altitudeGraphView.data = data
        altitudeGraphView.animate(yAxisDuration: 1.4)
        
    }
    
    
    @IBAction func startPressed(sender: AnyObject) {
        self.g_activityStart = NSDate()
        if !self.g_motionManager.accelerometerAvailable {
            print("Accelerometer not available")
            return
        }
        if self.g_motionManager.accelerometerActive {
            print("Already monitoring acceleration")
            return
        }
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            self.g_altimeter.startRelativeAltitudeUpdatesToQueue(self.g_altiQueue, withHandler: {
                (data, error) in
                let alt = data?.relativeAltitude
                self.altitudeLabel.text = "\(alt!) m"
                
                let timestamp = NSDate(timeInterval: (data?.timestamp)!, sinceDate: self.g_activityStart)
                
                let realm = try! Realm()
                
                let pt = AltDataPt()
                pt.altitude = (alt?.floatValue)!
                pt.time = timestamp
                
                realm.beginWrite()
                realm.add(pt)
                try! realm.commitWrite()
                
                
                // positive means going up
                let diff = alt!.floatValue - self.g_lastAltitudeMark.floatValue
                if diff > self.g_altitudeThresh {
                    self.g_lastAltitudeMark = alt!
                    self.playMotivation()
                }
            })
        }
        
        self.g_motionManager.accelerometerUpdateInterval = 0.1
        self.g_motionManager.startAccelerometerUpdatesToQueue(self.g_accelQueue, withHandler: {
            (data, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if error != nil {
                    print(error)
                    return
                }
                let xx = data!.acceleration.x
                let yy = data!.acceleration.y
                let zz = data!.acceleration.z
                self.xAccel.text = "\(xx)"
                self.yAccel.text = "\(yy)"
                self.zAccel.text = "\(zz)"
                
                for val in [xx, yy, zz] {
                    // likely a fall
                    if Float(abs(val)) > self.g_accelThresh {
                        self.playLanding()
                    }
                }
            })
        })
        stopButton.enabled = true
        startButton.enabled = false
    }
    
    @IBAction func fallSliderChanged(sender: UISlider) {
        let newVal = sender.value
        self.g_accelThresh = newVal
        self.accelThreshLabel.text = "Acceleration Threshold: \(newVal) G"
        
    }
    @IBAction func altitudeSliderChanged(sender: UISlider) {
        let newVal = sender.value
        self.g_altitudeThresh = newVal
        self.altitudeThreshLabel.text = "Altitude Threshold: \(newVal) m"
    }


}
