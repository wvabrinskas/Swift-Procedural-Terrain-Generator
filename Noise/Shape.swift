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
    
    init(device: MTLDevice, depth: Double, renderSize: CGSize, scale: Double) {
        
        let terrain = Terrain(type: .Islands, maxY: 1.0)
        
        var verticesArray = [[Vertex]]()

        let noise = Noise()
        noise.amplitude = terrain.amplitude
        noise.octaves = terrain.roughness
        
        var zOff:Double = 0
        let inc = 0.06
        
        var rowVerticies = [Vertex]()
        
        for z in stride(from: 0.0, through: depth, by: scale) {
            var xOff:Double = 0
            
            for x in stride(from: 0.0, through: Double(renderSize.width), by: scale) {
                let floatX = Float(x)
                let mappedX = Calculation.map(floatX, 0.0...Float(renderSize.width), -2.0...2.0)
                
                let floatZ = Float(z)
                let mappedZ = Calculation.map(floatZ, 0.0...Float(depth), -2.0...2.0)
                
                let y = noise.perlin(x: xOff, y: 0.0, z: zOff)
                
                let mappedY = Float(Calculation.map(y, 0.0...1.0, -2.0...2.0))
                
                var a:CGFloat = 0.0
                var r: CGFloat = 0.0
                var g: CGFloat = 0.0
                var b: CGFloat = 0.0
                
                Terrain.getColor(value: y, maxValue: 1.0).getRed(&r, green: &g, blue: &b, alpha: &a)
                
                let vertex = Vertex(x: mappedX, y: mappedY, z: mappedZ, r: Float(r), g: Float(g), b: Float(b), a: Float(a), nX: mappedX, nY: mappedY, nZ: mappedZ)

                rowVerticies.append(vertex)
                
                xOff += inc
            }
            verticesArray.append(rowVerticies)
            rowVerticies.removeAll()
            zOff += inc
        }

        var triplets = [Vertex]()
        for z in 0..<verticesArray.count {
            for x in 0..<verticesArray[z].count {
                
                guard verticesArray.indices.contains(z + 1) else { break }
                guard verticesArray[z].indices.contains(x + 1) else { break }
                
                let current = verticesArray[z][x]
                let right = verticesArray[z][x + 1]
                let top = verticesArray[z + 1][x]
                
                triplets.append(current)
                triplets.append(right)
                triplets.append(top)
            }
        }
        //print(sorted)
        
        super.init(name: "Shape", vertices: triplets, device: device)
    }
    
}
