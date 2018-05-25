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
    
    private func generatePointCloud(rect: CGRect) -> [[CGFloat]] {
        let xCount = Int(rect.size.width / self.spacing)
        let yCount = Int(rect.size.height / self.spacing)
        
        let points: [[CGFloat]] = Array(repeating: Array(repeating: 0, count: xCount), count: yCount)
        
        return points
    }
    
    func random() -> CGFloat {
        return CGFloat(arc4random_uniform(10)) / 10.0
    }
    
    private func randomIncrement() -> CGFloat {
        return CGFloat(Int.random(lower: UInt32(0), upper: UInt32(self.steepness))) / 100.0
    }
    
    func twoD(rect: CGRect) -> [[CGFloat]] {
        
        self.steepness = 7
        self.hillFactor = 100

        var pointCloud:[[CGFloat]] = self.generatePointCloud(rect: rect)
        
        var previousX = random()
        var previousDirection = 1

        let steps = 2
        
        for i in 0..<pointCloud.count {
            for j in 0..<pointCloud[i].count {
                
                let increment = CGFloat(Int.random(lower: UInt32(0), upper: UInt32(self.steepness))) / 100.0
                let x = i
                let y = j
                
                if x == 0 || y == 0 {
                    //print("top: \(top), left: \(left)")
                    var xAlpha:CGFloat = 0.0
                    if previousDirection == 1 {
                        //up average -> average + steepness
                        xAlpha = previousX + randomIncrement()
                        if xAlpha > 1.0 {
                            xAlpha = 1.0
                        }
                    } else {
                        //down average - steepness -> average
                        xAlpha = previousX - randomIncrement()
                        if xAlpha < 0.0 {
                            xAlpha = 0.0
                        }
                    }
                    previousX = xAlpha
                    pointCloud[x][y] = xAlpha
                }
                
                if x > (steps - 1) && y > (steps - 1) && y + steps < pointCloud[i].count && x + steps < pointCloud.count {
                    
                    let left = pointCloud[x][y - steps]
                    let top = pointCloud[x - steps][y]
                    
                    var bottom = pointCloud[x + steps][y]
                    var right = pointCloud[x][y + steps]
                    
                    var average = (left + top) / 2.0
                    
                    var alpha:CGFloat = 0.0
                    
                    if previousDirection == 1 {

                        if right == 0.0 {
                            right = average + increment
                            if right > 1.0 {
                                right = 1.0
                            }
                        }
                        if bottom == 0.0 {
                            bottom = average + increment
                            if bottom > 1.0 {
                                bottom = 1.0
                            }
                        }

                        average = (left + top + bottom + right) / 4.0

                        alpha = average + increment
                        if alpha > 1.0 {
                            alpha = 1.0
                        }
                        
                    } else {

                        if right == 0.0 {
                            right = average - increment
                            if right < 0.0 {
                                right = 0.0
                            }
                        }

                        if bottom == 0.0 {
                            bottom = average - increment
                            if bottom < 0.0 {
                                bottom = 0.0
                            }
                        }

                        average = (left + top + bottom + right) / 4.0
                        
                        alpha = average - increment
                        if alpha < 0.0 {
                            alpha = 0.0
                        }
                    }
                    
                    pointCloud[x + 1][y] = bottom
                    pointCloud[x][y + 1] = right
                    
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
