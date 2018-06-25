//
//  Light.swift
//  Noise
//
//  Created by William Vabrinskas on 6/25/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation

struct Light {
    
    var color: (Float, Float, Float)  // 1
    var ambientIntensity: Float       // 2
    
    static func size() -> Int {       // 3
        return MemoryLayout<Float>.size * 4
    }
    
    func raw() -> [Float] {
        let raw = [color.0, color.1, color.2, ambientIntensity]   // 4
        return raw
    }
}
