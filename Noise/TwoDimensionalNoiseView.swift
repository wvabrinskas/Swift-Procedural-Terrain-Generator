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
    
    private let graphLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let noise = Noise()
        noise.spacing = 0.5
        let alphas = noise.twoD(rect: self.frame)
        let ovalLayer = CAShapeLayer()
        ovalLayer.frame = self.frame
        
        UIColor.white.setFill()
        self.layer.addSublayer(ovalLayer)
        
        for x in 0..<alphas.count {
            for y in 0..<alphas[x].count {
                let newPath = UIBezierPath(rect: CGRect(x: CGFloat(y) * noise.spacing, y: CGFloat(x) * noise.spacing, width: noise.spacing, height: noise.spacing))
                let alpha = alphas[x][y]
                
                newPath.fill(with: .normal, alpha: alpha)
                ovalLayer.path = newPath.cgPath
            }
        }
    }
}
