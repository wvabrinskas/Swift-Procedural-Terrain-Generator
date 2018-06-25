//
//  Shape.swift
//  Noise
//
//  Created by William Vabrinskas on 6/25/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
import MetalKit

class Shape: Node {
    
    init(device: MTLDevice, xPoints: Int, yPoints: Int) {
        
        let terrain = Terrain(type: .Islands, maxY: 1.0)
        
        var verticesArray = [Vertex]()

        let noise = Noise()
        noise.amplitude = terrain.amplitude
        noise.octaves = terrain.roughness
        
        var yOff:Double = 0
        let inc = 0.01
        
        for z in 0..<yPoints {
            var xOff:Double = 0

            for x in 0..<xPoints {
                let floatX = Float(x)
                let mappedX = Calculation.map(floatX, 0.0...Float(xPoints), -1.0...1.0)
                
                let floatZ = Float(z)
                let mappedZ = Calculation.map(floatZ, 0.0...Float(yPoints), -1.0...1.0)
                
                let y = noise.perlin(x: xOff, y: yOff, z: 0.0)
                
                let mappedY = Float(Calculation.map(y, 0.0...1.0, -1.0...1.0))
                
                var a:CGFloat = 0.0
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
            
                Terrain.getColor(value: y, maxValue: 1.0).getRed(&r, green: &g, blue: &b, alpha: &a)
                
                let vertex = Vertex(x: mappedX, y: mappedY, z: mappedZ, r: Float(r), g: Float(g), b: Float(b), a: Float(a))
                print(vertex)
                verticesArray.append(vertex)

                xOff += inc
            }
            yOff += inc
        }
        
        super.init(name: "Shape", vertices: verticesArray, device: device)
    }
    
}
