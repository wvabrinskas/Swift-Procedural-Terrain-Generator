//
//  Terrain.swift
//  Noise
//
//  Created by William Vabrinskas on 6/5/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit


class Terrain {
    
    public var startPoint: Double!
    public var offset: Double!
    public var type: TerrainType!
    
    enum TerrainType:Int {
        case Plains, Ocean, Hills, Mountains, Marsh, Islands
    }
    
    init(type: TerrainType, maxY: Double) {
        self.type = type

        let max = maxY
        
        switch type {
        case .Hills:
            startPoint = 0.5 * max
            offset = 50.0
            break
        case .Ocean:
            startPoint = 0.1 * max
            offset = 20.0
            break
        case .Islands:
            startPoint = 0.12 * max
            offset = 40.0
            break
        case .Marsh:
            startPoint = 0.15 * max
            offset = 35.0
            break
        case .Mountains:
            startPoint = 0.7 * max
            offset = 100.0
            break
        case .Plains:
            startPoint = 0.2 * max
            offset = 10.0
            break
        }
    
    }
    
}
