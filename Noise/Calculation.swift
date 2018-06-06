//
//  Calculation.swift
//  Noise
//
//  Created by William Vabrinskas on 6/6/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation


class Calculation {
    
    static func constrain<N: BinaryInteger>(_ number: N, _ lower: N, _ upper: N) -> N {
        return max(min(number, upper), lower)
    }
    
    static func constrain<N: FloatingPoint>(_ number: N, _ lower: N, _ upper: N) -> N {
        return max(min(number, upper), lower)
    }
    
    static func map<N: FloatingPoint>(_ number: N, _ range:ClosedRange<N>, _ desiredRange:ClosedRange<N>) -> N {
        let origUpper = range.upperBound
        let origLower = range.lowerBound
        
        let desiredUpper = desiredRange.upperBound
        let desiredLower = desiredRange.lowerBound
        
        let newVal = (number - origLower) / (origUpper - origLower) * (desiredUpper - desiredLower) + desiredLower
        
        if desiredLower < desiredUpper {
            return Calculation.constrain(newVal, desiredLower, desiredUpper)
        } else {
            return Calculation.constrain(newVal, desiredUpper, desiredLower)
        }
        
    }
    
    static func map<N: BinaryInteger>(_ number: N, _ range:ClosedRange<N>, _ desiredRange:ClosedRange<N>) -> N {
        let origUpper = range.upperBound
        let origLower = range.lowerBound
        
        let desiredUpper = desiredRange.upperBound
        let desiredLower = desiredRange.lowerBound
        
        let newVal = (number - origLower) / (origUpper - origLower) * (desiredUpper - desiredLower) + desiredLower
        
        if desiredLower < desiredUpper {
            return Calculation.constrain(newVal, desiredLower, desiredUpper)
        } else {
            return Calculation.constrain(newVal, desiredUpper, desiredLower)
        }
    }
}
