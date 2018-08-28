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
    var direction: (Float, Float, Float)
    var diffuseIntensity: Float
    
    static func size() -> Int {       // 3
        return MemoryLayout<Float>.size * 8
    }
    
    func raw() -> [Float] {
        let raw = [color.0, color.1, color.2, ambientIntensity, direction.0, direction.1, direction.2, diffuseIntensity]
        return raw
    }
}
