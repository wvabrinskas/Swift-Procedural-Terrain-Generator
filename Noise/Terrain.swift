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
        amplitude = 0.4

        switch type {
        case .Hills:
            startPoint = 0.20 * max
            offset = 0.4
            roughness = 8
            break
        case .Ocean:
            startPoint = 0.03 * max
            offset = 0.1
            roughness = 4
            break
        case .Islands:
            startPoint = 0.03 * max
            offset = 0.5
            roughness = 4
            break
        case .Marsh:
            startPoint = 0.06 * max
            offset = 0.2
            roughness = 8
            break
        case .Mountains:
            startPoint = 0.5 * max
            offset = 1.01
            roughness = 12
            break
        case .Plains:
            startPoint = 0.2 * max
            offset = 0.2
            roughness = 8
            break
        }
    
    }
    
}
