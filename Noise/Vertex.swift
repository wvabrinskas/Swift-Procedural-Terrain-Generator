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

    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
    
}
