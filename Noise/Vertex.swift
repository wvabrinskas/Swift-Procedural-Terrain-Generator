//
//  Vertex.swift
//  Noise
//
//  Created by William Vabrinskas on 6/25/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import Foundation
struct Vertex {
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    var nX,nY,nZ: Float  // normal

    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a,nX,nY,nZ]
    }
    
    static func size() -> Int {       // 3
        return MemoryLayout<Float>.size * 10
    }
    
}
