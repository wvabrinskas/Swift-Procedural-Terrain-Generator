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
//generates a "Perlin" like noise for procedural generation
class Noise {
    //how quickly the change is between each point
    var steepness:UInt32 = 30
    //the x spacing between each point
    var spacing:CGFloat = 10.0
    //how likely the y direction of the noise changes between each point
    var hillFactor:UInt32 = 10
    
    private lazy var p:[Int] = {
        var newP = [Int]()
        for i in 0..<512 {
            newP.append(permutation[i % 256])
        }
        return newP
    }()
    
    private let permutation: [Int] = [151,160,137,91,90,15,
                              131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
                              190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
                              88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
                              77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
                              102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
                              135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
                              5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
                              223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
                              129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
                              251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
                              49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
                              138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180]
    
    private func lerp(t: Double, a: Double, b: Double) -> Double {
        return a + t * (b - a)
    }
    
    private func fade(t: Double) -> Double {
        return t * t * t * (t * (t * 6 - 15) + 10)
    }
    
    private func grad(hash: Int, x: Double, y: Double, z: Double) -> Double {
        let h = hash & 15
        let u: Double = h < 8 ? x : y
        let v: Double = h < 4 ? y : h == 12 || h == 14 ? x : z
        
        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
    }
    
    public func perlin(x: Double, y: Double, z: Double) -> Double {
        
        var x = x
        var y = y
        var z = z
        
        let X:Int = Int(floor(x)) & 255
        let Y:Int = Int(floor(y)) & 255
        let Z:Int = Int(floor(z)) & 255
        
        x -= floor(x)
        y -= floor(y)
        z -= floor(z)
//
        let u:Double = fade(t: x)
        let v:Double = fade(t: y)
        let w:Double = fade(t: z)
        
        let A: Int = p[X] + Y
        let AA:Int = p[A] + Z
        let AB:Int = p[A + 1] + Z
        
        let B: Int =  p[X + 1] + Y
        let BA: Int = p[B] + Z
        let BB: Int = p[B + 1] + Z
        
        return lerp(t: w, a: lerp(t: v, a: lerp(t: u, a: grad(hash: p[AA], x: x, y: y, z: z),  // AND ADD
                    b: grad(hash: p[BA], x: x-1, y: y, z: z)), // BLENDED
                    b: lerp(t: u, a: grad(hash: p[AB], x: x, y: y-1, z: z   ),  // RESULTS
                    b: grad(hash: p[BB], x: x-1, y: y-1, z: z   ))),// FROM  8
                    b: lerp(t: v, a: lerp(t: u, a: grad(hash: p[AA+1], x: x, y: y, z: z-1 ),  // CORNERS
                    b: grad(hash: p[BA+1], x: x-1, y: y, z: z-1 )), // OF CUBE
                    b: lerp(t: u, a: grad(hash: p[AB+1], x: x  , y: y-1, z: z-1 ),
                    b: grad(hash: p[BB+1], x: x-1, y: y-1, z: z-1 ))))
        
    }
    
    
    //returns an array of CGPoints describing the noise generated
    func generate(samples: Int, maxHeight: CGFloat, minHeight:CGFloat) -> [CGPoint] {
        var values = [CGPoint]()
        
        let max = maxHeight
        let min = minHeight
        
        var previousY = CGFloat(arc4random_uniform(UInt32(min)))

        var previousDirection = 1
        
        for x in 0..<samples {
            var newY = previousY
            
            if previousDirection == 0 {
                let down = CGFloat(Int.random(lower: UInt32(previousY), upper: UInt32(previousY) + arc4random_uniform(steepness)))
                newY = down
                if down > min {
                    newY = min
                }
            } else {
                let preUp = previousY - CGFloat(arc4random_uniform(steepness))
                if preUp < 0 {
                    newY = 0
                } else {
                    let up = CGFloat(Int.random(lower:  UInt32(preUp), upper: UInt32(previousY)))
                    newY = up
                    if up < max {
                        newY = max
                    }
                }
            }
            
            let randomDirection = arc4random_uniform(hillFactor)
            if randomDirection == 0 {
                if previousDirection == 0 {
                    previousDirection = 1
                } else {
                    previousDirection = 0
                }
            }
            
            previousY = newY
            let point = CGPoint(x: CGFloat(x) * spacing, y: newY)
            values.append(point)
        }
        return values
    }
    
}
