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
    public var amplitude: Double!
    public var roughness: Int!
    
    enum TerrainType:Int {
        case Plains, Ocean, Hills, Mountains, Marsh, Islands
    }
    
    init(type: TerrainType, maxY: Double) {
        self.type = type
        let max = maxY
        
        switch type {
        case .Hills:
            startPoint = 0.20 * max
            offset = 40.0
            roughness = 2
            amplitude = 0.95
            break
        case .Ocean:
            startPoint = 0.03 * max
            offset = 20.0
            roughness = 4
            amplitude = 0.8
            break
        case .Islands:
            startPoint = 0.04 * max
            offset = 40.0
            roughness = 3
            amplitude = 0.9
            break
        case .Marsh:
            startPoint = 0.05 * max
            offset = 0.2
            roughness = 3
            amplitude = 0.001
            break
        case .Mountains:
            startPoint = 0.5 * max
            offset = 1.2
            amplitude = 0.6
            roughness = 5
            break
        case .Plains:
            startPoint = 0.2 * max
            offset = 10.0
            amplitude = 0.2
            roughness = 2
            break
        }
    
    }
    
}
