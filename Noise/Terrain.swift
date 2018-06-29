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
    public var cameraStartPoint: Double!
    
    enum TerrainType:Int {
        case Plains, Ocean, Hills, Mountains, Marsh, Islands
    }
    
    public class func getGradientColor(value: Double, maxValue: CGFloat) -> UIColor {
        var endValue = value
        
        let deepBlue = UIColor(red: 36.0/255.0, green: 95.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        let lightBlue = UIColor(red: 67.0/255.0, green: 180.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        let sand = UIColor(red: 221.0/255.0, green: 200.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        let green = UIColor(red: 24.0/255.0, green: 169.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        let brown = UIColor(red: 179.0/255.0, green: 114.0/255.0, blue: 25.0/255.0, alpha: 1.0)
        let gray = UIColor.lightGray
        let white = UIColor.white
        
        let terrainColors:[[String: Any]] = [
            ["range" : 0.0...0.2  , "colors" : (min: white, max: gray)],
            ["range" : 0.2...0.5 , "colors" : (min: gray, max: brown)],
            ["range" : 0.5...0.7 , "colors" : (min: brown, max: green)],
            ["range" : 0.7...0.8 , "colors" : (min: green, max: sand)],
            ["range" : 0.8...0.85 , "colors" : (min: sand, max: lightBlue)],
            ["range" : 0.85...0.9 , "colors" : (min: lightBlue, max: deepBlue)],
            ["range" : 0.9...1.0 , "colors" : (min: deepBlue, max: deepBlue)]
        ]
        
        var terrainColorSpace: (min: UIColor, max: UIColor)!
        
        for terrain in terrainColors {
            let range = terrain["range"] as! ClosedRange<Double>
            let colors = terrain["colors"] as! (min: UIColor, max: UIColor)
            if range.contains(Double(value)) {
                endValue = Calculation.map(value, range.lowerBound...range.upperBound, 0...1)
                terrainColorSpace = colors
                break
            }
        }
        
        var minAlpha:CGFloat = 0.0
        var minRed: CGFloat = 0.0
        var minGreen: CGFloat = 0.0
        var minBlue: CGFloat = 0.0
        
        var maxAlpha:CGFloat = 0.0
        var maxRed: CGFloat = 0.0
        var maxGreen: CGFloat = 0.0
        var maxBlue: CGFloat = 0.0
        
        terrainColorSpace.min.getRed(&minRed, green: &minGreen, blue: &minBlue, alpha: &minAlpha)
        terrainColorSpace.max.getRed(&maxRed, green: &maxGreen, blue: &maxBlue, alpha: &maxAlpha)
        
        let resultRed = minRed + CGFloat(endValue) * (maxRed - minRed)
        let resultGreen = minGreen + CGFloat(endValue) * (maxGreen - minGreen)
        let resultBlue = minBlue + CGFloat(endValue) * (maxBlue - minBlue)
        
        return UIColor(red: resultRed, green: resultGreen, blue: resultBlue, alpha: 1.0)
        
    }
    
    public class func get3DColor(value: Double, maxValue: CGFloat) -> UIColor {
        let deepBlue = UIColor(red: 36.0/255.0, green: 95.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        let lightBlue = UIColor(red: 67.0/255.0, green: 180.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        let sand = UIColor(red: 221.0/255.0, green: 200.0/255.0, blue: 146.0/255.0, alpha: 1.0)
        let green = UIColor(red: 24.0/255.0, green: 169.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        let brown = UIColor(red: 179.0/255.0, green: 114.0/255.0, blue: 25.0/255.0, alpha: 1.0)
        let gray = UIColor.lightGray
        let darkGray = UIColor.lightGray
        let white = UIColor.white
        
        let terrainColors:[Double : UIColor] = [
            0.2 : white,
            0.25 : darkGray,
            0.3 : gray,
            0.5 : brown,
            0.75: green,
            0.8 : sand,
            0.85 : lightBlue,
            1.0 : deepBlue
        ]
        
        let sorted = terrainColors.sorted(by: { $0.key < $1.key} )
        
        for terrain in sorted {
            let heightValue = Double(maxValue) * terrain.key
            
            if value < heightValue {
                return terrain.value
            }
        }
        
        return UIColor(red: 36.0/255.0, green: 95.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    }
    
    
    public class func getColor(value: Double, maxValue: CGFloat) -> UIColor {
        
        let terrainColors:[Double : UIColor] = [
            0.2 : UIColor.white,
            0.5 : UIColor.lightGray,
            0.7 : UIColor(red: 179.0/255.0, green: 114.0/255.0, blue: 25.0/255.0, alpha: 1.0),
            0.85: UIColor(red: 24.0/255.0, green: 169.0/255.0, blue: 59.0/255.0, alpha: 1.0),
            0.9 : UIColor(red: 67.0/255.0, green: 180.0/255.0, blue: 212.0/255.0, alpha: 1.0),
            1.0 : UIColor(red: 36.0/255.0, green: 95.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        ]
        
        let sorted = terrainColors.sorted(by: { $0.key < $1.key} )
        
        for terrain in sorted {
            let heightValue = Double(maxValue) * terrain.key
            
            if value < heightValue {
                return terrain.value
            }
        }
        
        return UIColor(red: 36.0/255.0, green: 95.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    }
    
    init(type: TerrainType, maxY: Double, cameraMax: Double) {
        self.type = type
        let max = maxY
        amplitude = 0.4

        switch type {
        case .Hills:
            startPoint = 0.20 * max
            cameraStartPoint = 0.20 * cameraMax
            offset = 0.4
            roughness = 8
            break
        case .Ocean:
            startPoint = 0.03 * max
            cameraStartPoint = 0.03 * cameraMax
            offset = 0.1
            roughness = 4
            break
        case .Islands:
            startPoint = 0.03 * max
            cameraStartPoint = 0.03 * cameraMax
            offset = 0.34
            roughness = 12
            break
        case .Marsh:
            startPoint = 0.06 * max
            cameraStartPoint = 0.06 * cameraMax
            offset = 0.2
            roughness = 8
            break
        case .Mountains:
            startPoint = 0.5 * max
            cameraStartPoint = 0.5 * cameraMax
            offset = 1.01
            roughness = 12
            break
        case .Plains:
            startPoint = 0.2 * max
            cameraStartPoint = 0.2 * cameraMax
            offset = 0.2
            roughness = 8
            break
        }
    
    }
    
}
