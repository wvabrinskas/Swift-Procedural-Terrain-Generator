//
//  ViewController.swift
//  Noise
//
//  Created by William Vabrinskas on 5/18/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sampleNumberLabel: UILabel!
    
    private lazy var height = self.view.frame.size.height * 0.7
    
    private var timer:Timer!
    
    private let ellipseWidth:CGFloat = 1.0
    private let ellipseHeight:CGFloat = 1.0
    
    private let graphLayer = CAShapeLayer()

    private var previousLine: CGMutablePath!
    private var previousLineLayer: CAShapeLayer!
    private var previousColor: CGColor!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        graphLayer.backgroundColor = UIColor(red: 44.0/255.0, green: 48.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor
        graphLayer.frame = CGRect(x: 0, y: self.view.frame.midY - (height / 2.0), width: self.view.frame.size.width, height: height)
        self.contentView.layer.addSublayer(graphLayer)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.backgroundColor = .clear
        view.backgroundColor = .clear
        startOneDNoise(samples: 2000)
//        let twoD = TwoDimensionalNoiseView(frame: graphLayer.frame)
//        self.view.addSubview(twoD)
    }
    
    
    private func clear() {
        self.sampleNumberLabel.text = "0"

        timer?.invalidate()
        self.graphLayer.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })

    }
    
    private func getColor(point: CGPoint) -> CGColor {
        
        let terrainColors:[CGFloat : CGColor] = [
                             0.2 : UIColor.white.cgColor,
                             0.5 : UIColor.lightGray.cgColor,
                             0.7 : UIColor(red: 179.0/255.0, green: 114.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor,
                             0.85: UIColor(red: 24.0/255.0, green: 169.0/255.0, blue: 59.0/255.0, alpha: 1.0).cgColor,
                             0.9 : UIColor(red: 67.0/255.0, green: 180.0/255.0, blue: 212.0/255.0, alpha: 1.0).cgColor,
                             1.0 : UIColor(red: 36.0/255.0, green: 95.0/255.0, blue: 217.0/255.0, alpha: 1.0).cgColor
                            ]
        
        let sorted = terrainColors.sorted(by: { $0.key < $1.key} )
        
        for terrain in sorted {
            let y = point.y
            let heightValue = self.graphLayer.bounds.height * terrain.key
            
            if y < heightValue {
                return terrain.value
            }
        }
        
        return UIColor.white.cgColor
    }
    
    private func addGraphics(index: Int, previousPoint: CGPoint?, currentPoint: CGPoint) {
        
        let shouldGetNewLine:Bool = {
            if previousColor == self.getColor(point: currentPoint) {
                return false
            }
            return true
        }()
        
        var line = CGMutablePath()

        if !shouldGetNewLine {
            line = previousLine
        }
        
        if previousPoint != nil {
            line.move(to: CGPoint(x: previousPoint!.x - (0.5 * self.ellipseWidth), y: previousPoint!.y))
            line.addLine(to: CGPoint(x: currentPoint.x - (0.5 * self.ellipseWidth), y: currentPoint.y))
        }
        
        let lineLayer = !shouldGetNewLine ? previousLineLayer! : CAShapeLayer()

        lineLayer.lineWidth = 2.0
        lineLayer.lineCap = kCALineCapRound
        lineLayer.strokeColor = self.getColor(point: currentPoint)
        lineLayer.path = line
        
        if shouldGetNewLine {
            self.graphLayer.addSublayer(lineLayer)
        }
        
        previousLineLayer = lineLayer
        previousColor = self.getColor(point: currentPoint)
        previousLine = line

        let oval = UIBezierPath(ovalIn: CGRect(x:currentPoint.x, y: currentPoint.y, width: self.ellipseWidth, height: self.ellipseHeight))
        let ovalLayer = CAShapeLayer()

        ovalLayer.fillColor = self.getColor(point: currentPoint)
        ovalLayer.strokeColor = UIColor.clear.cgColor
        ovalLayer.path = oval.cgPath
        
        self.graphLayer.addSublayer(ovalLayer)
        
        if currentPoint.x >= self.view.frame.maxX - 107 {
            self.graphLayer.frame.size = CGSize(width: self.graphLayer.frame.size.width + (self.view.frame.maxX - 107), height:  self.graphLayer.frame.size.height)
            self.scrollView.setContentOffset(CGPoint(x: currentPoint.x - (self.view.frame.maxX - 107), y: 0), animated: true)
        }
        
    }
    
    func getTerrain(terrainType: Terrain.TerrainType) -> Terrain {
        let max = graphLayer.bounds.maxY
        return Terrain(type: terrainType, maxY: Double(max))
    }
    
    private func startOneDNoise(samples: Int) {
        self.clear()

        var i = 0
        var xOff = 0.0
        
        self.scrollView.contentSize = CGSize(width: CGFloat(samples) + 107, height: self.scrollView.contentSize.height)

        var previousPoint: CGPoint?

        let max = Double(graphLayer.bounds.minY)
        let min = Double(graphLayer.bounds.maxY)
        
        let terrain = getTerrain(terrainType: .Hills)

        let noise = Noise()
        noise.amplitude = terrain.amplitude
        noise.octaves = terrain.roughness
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { (timer) in
            if i == samples {
                timer.invalidate()
                return
            }
            
            if i >= samples - 1 {
                DispatchQueue.main.async {
                    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.contentView.frame.size.height), animated: true)
                }
                timer.invalidate()
            }
            
            self.sampleNumberLabel.text = "\(i + 1)"
            
            
            let noise = noise.perlin(x: xOff, y: 0.0, z: 0.0)
            let mappedNoise = min - (((Calculation.map(noise, 0...1, max...min)) * terrain.offset) + terrain.startPoint)
            var y = mappedNoise//(noise * terrain.offset) + terrain.startPoint

            if y < max {
                y = max
            } else if y > min {
                y = min
            }
            
            let current = CGPoint(x: CGFloat(i), y: CGFloat(y))

            let currentPoint = CGPoint(x: current.x, y: current.y + self.ellipseHeight)
            self.addGraphics(index: i, previousPoint: previousPoint, currentPoint: currentPoint)
            
            previousPoint = currentPoint
            
            xOff += 0.01
            i += 1
        }
        timer.fire()
        
    }

}

