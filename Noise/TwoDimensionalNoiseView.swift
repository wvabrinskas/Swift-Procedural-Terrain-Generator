//
//  TwoDimensionalNoiseView.swift
//  Noise
//
//  Created by William Vabrinskas on 5/24/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import UIKit


class TwoDimensionalNoiseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        start()
    }
    
    func getTerrain(terrainType: Terrain.TerrainType) -> Terrain {
        let max = 1.0
        return Terrain(type: terrainType, maxY: Double(max))
    }
    
    func start() {
        
        let noiseLayer = CAShapeLayer()
        noiseLayer.frame = self.frame
        noiseLayer.drawsAsynchronously = true

        self.layer.addSublayer(noiseLayer)

        var yOff:Double = 0
        let inc = 0.01
        
        let terrain = getTerrain(terrainType: .Islands)
        
        let noise = Noise()
        noise.amplitude = terrain.amplitude
        noise.octaves = terrain.roughness
        
        for y in stride(from: 0.0, through: self.frame.size.height, by: 1.0) {
            var xOff:Double = 0
            
            for x in stride(from: 0.0, through: self.frame.size.width, by: 1.0) {
                let newPath = UIBezierPath(rect: CGRect(x: CGFloat(x), y: CGFloat(y), width: 1.0, height: 1.0))
                
                let value = (noise.perlin(x: xOff, y: yOff, z: 0.0) * terrain.offset) + terrain.startPoint
                var alpha:CGFloat = CGFloat(value)

                if alpha > 1.0 {
                    alpha = 1.0
                } else if alpha < 0.0 {
                    alpha = 0.0
                }
                Terrain.getGradientColor(value: Double(1.0 - alpha), maxValue: 1.0).setFill()
                //UIColor(red: alpha, green: alpha, blue: alpha, alpha: 1.0).setFill()
                
                newPath.fill()
                noiseLayer.path = newPath.cgPath
                
                xOff += inc
            }
            yOff += inc
        }
    }
}
