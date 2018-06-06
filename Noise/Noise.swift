//
//  Noise.swift
//  Noise
//
//  Created by William Vabrinskas on 5/18/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    static func random(lower: UInt32, upper: UInt32) -> UInt32 {
        return arc4random_uniform(upper - lower) + lower
    }
}

//generates Perlin Noise for procedural generation
//algorithm adapted from the p5.js library https://github.com/processing/p5.js/blob/master/src/math/noise.js
class Noise {
    
    private var yWrapB = 4
    private lazy var yWrap = 1 << yWrapB
    private var zWrapB = 8
    private lazy var zWrap = 1 << zWrapB
    private var size = 4095
    
    var octaves = 4
    var amplitude = 0.5

    private lazy var perlin:[Double] = {
        var p = [Double]()
        for _ in 0..<size + 1 {
            let random = Double(arc4random_uniform(1000)) / 1000.0
            p.append(random)
        }
        return p
    }()
    
    private func scaledCosine(_ i: Double) -> Double {
        return 0.5 * (1.0 - cos(i * Double.pi))
    }
    
    public func perlin(x: Double, y: Double, z: Double) -> Double {
        
        var x = x
        var y = y
        var z = z
        
        if (x < 0) {
            x = -x;
        }
        if (y < 0) {
            y = -y;
        }
        if (z < 0) {
            z = -z;
        }
        
        var xi = Int(floor(x))
        var yi = Int(floor(y))
        var zi = Int(floor(z))
        
        var xf = x - Double(xi)
        var yf = y - Double(yi)
        var zf = z - Double(zi)
        
        var rxf = 0.0
        var ryf = 0.0
        
        var r = 0.0
        var ampl = 0.5
        
        var n1 = 0.0
        var n2 = 0.0
        var n3 = 0.0
        
        for _ in 0..<octaves {

            var of = xi + (yi << yWrapB) + (zi << zWrapB)
            
            rxf = scaledCosine(xf)
            ryf = scaledCosine(yf)
            
            n1 = perlin[of & size]
            n1 += rxf * (perlin[(of + 1) & size] - n1)
            n2 = perlin[(of + yWrap) & size]
            n2 += rxf * (perlin[(of + yWrap + 1) & size] - n2)
            n1 += ryf * (n2 - n1)
            
            of += zWrap
            n2 = perlin[of & size]
            n2 += rxf * (perlin[(of + 1) & size] - n2)
            n3 = perlin[(of + yWrap) & size]
            n3 += rxf * (perlin[(of + yWrap + 1) & size] - n3)
            n2 += ryf * (n3 - n2)
            
            n1 += scaledCosine(zf) * (n2 - n1)
        
            r += n1 * ampl
            ampl *= amplitude
            xi <<= 1
            xf *= 2
            yi <<= 1
            yf *= 2
            zi <<= 1
            zf *= 2
            
            if (xf >= 1.0) {
                xi += 1
                xf -= 1
            }
            if (yf >= 1.0) {
                yi += 1
                yf -= 1
            }
            if (zf >= 1.0) {
                zi += 1
                zf -= 1
            }
        }
        return r
    }
    
}
