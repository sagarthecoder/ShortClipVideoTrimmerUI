//
//  CMTime+Extension.swift
//  ShortClipVideoTrimmerUI
//
//  Created by Sagar on 9/23/22.
//

import Foundation
import AVFoundation
import UIKit

extension CMTime {
    var asDouble: Double {
        get {
            return Double(self.value) / Double(self.timescale)
        }
    }
    var asFloat: Float {
        get {
            return Float(self.value) / Float(self.timescale)
        }
    }
}
