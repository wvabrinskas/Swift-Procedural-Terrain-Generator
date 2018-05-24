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
    
    func random() -> CGFloat {
        return CGFloat(arc4random_uniform(10)) / 10.0
    }
    
    func twoD(rect: CGRect) -> [[CGFloat]] {
        let xCount = Int(rect.size.width / self.spacing)
        let yCount = Int(rect.size.height / self.spacing)
    
        var pointCloud = [[CGFloat]]()
        
        let steep:CGFloat = 9.0

        var xArray = [CGFloat]()
        var previousX = random()
        var previousXDirection = 1
        
        func fillXArray() {
            xArray.removeAll()
            for _ in 0..<xCount {
                
                var newAlpha = previousX
                
                var alpha:CGFloat = 0.0
                //print("top: \(top), left: \(left)")
                if previousXDirection == 1 {
                    //up average -> average + steepness
                    alpha = CGFloat(Int.random(lower: UInt32(previousX), upper: UInt32(previousX + steep))) / 10.0
                } else {
                    //down average - steepness -> average
                    var lower = previousX - steep
                    if lower < 0 {
                        lower = 0
                    }
                    alpha = CGFloat(Int.random(lower: UInt32(lower), upper: UInt32(previousX))) / 10.0
                }
                
                newAlpha = alpha
                previousX = alpha
                
                let randomXDirection = arc4random_uniform(hillFactor)
                
                if randomXDirection == 0 {
                    if previousXDirection == 0 {
                        previousXDirection = 1
                    } else {
                        previousXDirection = 0
                    }
                }
                xArray.append(newAlpha)
            }
        }

        for _ in 0..<yCount {
            fillXArray()
            pointCloud.append(xArray)
        }
        
        var previousDirection = 1

        for i in 0..<pointCloud.count {
            for j in 0..<pointCloud[i].count {

                let x = i
                let y = j
                
                if x > 0 && y > 0 && y + 1 < pointCloud[i].count && x + 1 < pointCloud.count {
                    
                    let top = pointCloud[x][y - 1]
                    let left = pointCloud[x - 1][y]
                    let right = pointCloud[x + 1][y]
                    let bottom = pointCloud[x][y + 1]
                    
                    let average = (right + bottom + top + left) / 4.0
                    var alpha:CGFloat = 0.0
                    //print("top: \(top), left: \(left)")
                    if previousDirection == 1 {
                        //up average -> average + steepness
                        alpha = CGFloat(Int.random(lower: UInt32(average), upper: UInt32(average + steep))) / 10.0
                    } else {
                        //down average - steepness -> average
                        var lower = average - steep
                        if lower < 0 {
                            lower = 0
                        }
                        alpha = CGFloat(Int.random(lower: UInt32(lower), upper: UInt32(average))) / 10.0
                    }
                    pointCloud[x][y] = alpha
                    
                }
                
                let randomDirection = arc4random_uniform(hillFactor)
                if randomDirection == 0 {
                    if previousDirection == 0 {
                        previousDirection = 1
                    } else {
                        previousDirection = 0
                    }
                }
            }
        }
        return pointCloud
    }
}
