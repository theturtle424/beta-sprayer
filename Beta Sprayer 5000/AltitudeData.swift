//
//  AltitudeData.swift
//  Beta Sprayer 5000
//
//  Created by Franklin DeHart on 7/31/16.
//  Copyright © 2016 Franklin DeHart. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * Data point for altitude data
 */
class AltDataPt: Object {
    dynamic var time = NSDate()
    dynamic var altitude = 0.0
}