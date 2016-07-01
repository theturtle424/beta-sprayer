//
//  ViewController.swift
//  Beta Sprayer 5000
//
//  Created by Franklin DeHart on 6/19/16.
//  Copyright © 2016 Franklin DeHart. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation


class ViewController: UIViewController {
    
    var g_motionManager = CMMotionManager()
    var g_altimeter = CMAltimeter()
    var g_altiQueue = NSOperationQueue()
    var g_accelQueue = NSOperationQueue()
    var g_motionQueue = NSOperationQueue()
    var g_audioPlayer = AVAudioPlayer()
    var g_count = 0
    var g_curAlt = NSNumber.init(float: 0.0)

//    @IBOutlet weak var amountSlider: UISlider!
//    @IBOutlet weak var typeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error")
            return
        }
//        }
//        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
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
        self.g_curAlt = NSNumber.init(float: 0.0)
    }


    @IBAction func startPressed(sender: AnyObject) {
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
                print("update: \(alt)")
                
                // positive means going up
                let diff = alt!.floatValue - self.g_curAlt.floatValue
                let heightInterval = Float(1.1)
                
                if alt?.intValue < 0 {
                    print("going down")
                }
                if diff > heightInterval {
                    print("going up")
                    self.g_curAlt = alt!
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
                
                for val in [xx, yy, zz] {
                    // likely a fall
                    if abs(val) > 1.7 {
                        print("big accel: \(val)")
                        self.playLanding()
                    }
                }
            })
        })
    }

}

