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
    var g_accelQueue = NSOperationQueue()
    var g_motionQueue = NSOperationQueue()
    var g_audioPlayer = AVAudioPlayer()
    var g_count = 0

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
    
    func handle_motion_data(data: CMMotionActivity!) {
//        g_count+=1;
//        var trigger = g_count % (15 - Int(amountSlider.value));
//        if trigger != 0 {
//            return;
//        }
//        
//        var allFiles = NSBundle.mainBundle().pathsForResourcesOfType("m4a", inDirectory: "");
//        allFiles.count;
//        var choice = Int(arc4random_uniform(UInt32(allFiles.count)));
//        print(allFiles[choice]);
//        
//        var sound = NSURL(fileURLWithPath: allFiles[choice] as! String)
//        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//        AVAudioSession.sharedInstance().setActive(true, error: nil)
//        var error:NSError?
//        g_audioPlayer = AVAudioPlayer(contentsOfURL: sound, error: &error)
//        g_audioPlayer.prepareToPlay()
//        g_audioPlayer.play()
    }
    
    
    @IBAction func stopPressed(sender: AnyObject) {
        if g_motionManager.accelerometerActive {
            g_motionManager.stopAccelerometerUpdates()
        }
    }


    @IBAction func startPressed(sender: AnyObject) {
        if !g_motionManager.accelerometerAvailable {
            print("Accelerometer not available")
            return
        }
        if g_motionManager.accelerometerActive {
            print("Already monitoring acceleration")
            return
        }
        
        g_motionManager.accelerometerUpdateInterval = 0.1
        g_motionManager.startAccelerometerUpdatesToQueue(g_accelQueue, withHandler: {
            (data, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if error != nil {
                    print(error)
                    return
                }
                var xx = data!.acceleration.x
                var yy = -data!.acceleration.y
//                var angle = atan2(yy, xx)
                var zz = data!.acceleration.z
                if abs(xx) > 1.1 {
                    print("xx", xx)
                }
                if abs(yy) > 1.5 {
                    print("yy", yy)
                }
                if abs(zz) > 1.5 {
                    print("zz", zz)
                }
                
            })
            
        })
    }
    
    
//        if(g_motionManager.accelerometerAvailable)
//        {
//            g_motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: {
//                accelerometerData,error in
//                let acceleration = accelerometerData!.acceleration
//                var accelerationZ = CGFloat(acceleration.z)
//                print(accelerationZ)
//                g_audioPlayer =
//                
//            })
////        if CMMotionManager. {
////            g_motion.
////        } else {
////            print("no activity")
//        }
//    }?

}

