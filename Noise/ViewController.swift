//
//  ViewController.swift
//  Noise
//
//  Created by William Vabrinskas on 5/18/18.
//  Copyright © 2018 William Vabrinskas. All rights reserved.
//

import UIKit
import MetalKit
import QuartzCore

class ViewController: UIViewController, UITextFieldDelegate, MTKViewDelegate {
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
    
    var allocator:MTKMeshBufferAllocator!
    var buffer: MDLMeshBuffer!
    var light: MDLLight!
    let size = CGSize(width: 300, height: 300)
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var gfxTimer: CADisplayLink!
    
    var metalLayer: CAMetalLayer!
    var objectToDraw: Shape!
    var projectionMatrix: float4x4!
    var worldModelMatrix = float4x4()
    
    lazy var pan = UIPanGestureRecognizer.init(target: self, action: #selector(pan(sender:)))
    
    lazy var mtkView: MTKView! =  {
        let metalView = MTKView(frame: self.graphLayer.frame)
        metalView.delegate = self
        metalView.preferredFramesPerSecond = 60
        metalView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        return metalView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        graphLayer.backgroundColor = UIColor(red: 44.0/255.0, green: 48.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor
        graphLayer.frame = CGRect(x: 0, y: self.view.frame.midY - (height / 2.0), width: self.view.frame.size.width, height: height)
        self.contentView.layer.addSublayer(graphLayer)
        
        run3DRender()
        
    }
    
    private func run3DRender() {
        self.view.addSubview(mtkView)
        
        let device = MTLCreateSystemDefaultDevice()!
        
        mtkView.device = device
        
        
        let mapScale:ClosedRange<Float> = -20.0...20.0
        let terrain = Terrain(type: .Islands, maxY: 1.0, cameraMax: Double(mapScale.upperBound))

        objectToDraw = Shape(device: device, depth: 1500.0, width: 1500.0, scale: 10.0, terrain: terrain, mapScale: mapScale)
        
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0),
                                                             aspectRatio: Float(graphLayer.bounds.size.width / graphLayer.bounds.size.height),
                                                             nearZ: 0.0, farZ: 4.0)
        
        worldModelMatrix.translate(0.0, y: -0.5, z: -5.1)
        worldModelMatrix.rotateAroundX(float4x4.degrees(toRad: 35), y: 0.0, z: 0.0)
        
        pan.maximumNumberOfTouches = 2
        mtkView.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(pinch(sender:)))
        mtkView.addGestureRecognizer(pinch)

        objectToDraw.positionZ = -2.15
        objectToDraw.positionY -= Float(terrain.cameraStartPoint)
        objectToDraw.light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.2, direction: (1.0, Float(terrain.cameraStartPoint), -1.0), diffuseIntensity: 0.1)
    }
    
    @objc func pan(sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: mtkView)
        
        if sender.numberOfTouches == 2 {
            if velocity.y > 0 {
                objectToDraw.positionY -= 0.1
            } else if velocity.y < 0 {
                objectToDraw.positionY += 0.1
            }
            
            if velocity.x > 0 {
                objectToDraw.positionX -= 0.1
            } else if velocity.x < 0 {
                objectToDraw.positionX += 0.1
            }
            
            
        } else {
            if velocity.x > 0 {
                objectToDraw.rotationY += 0.1
            } else if velocity.x < 0 {
                objectToDraw.rotationY -= 0.1
            }
            
            if velocity.y > 0 {
                objectToDraw.rotationX += 0.1
            } else if velocity.y < 0 {
                objectToDraw.rotationX -= 0.1
            }
        }
        
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        if pan.state != .began {
            if sender.scale > 1.0 {
                objectToDraw.positionZ += 0.3
            } else {
                objectToDraw.positionZ -= 0.3
            }
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
    
    func render(_ drawable: CAMetalDrawable?) {
        guard let drawable = drawable else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.backgroundColor = .clear
        view.backgroundColor = .clear
        //startOneDNoise(samples: 2000)
        //        let twoD = TwoDimensionalNoiseView(frame: graphLayer.frame)
        //        twoD.type = .Mountains
        //        self.view.addSubview(twoD)
    }
    
    
    private func clear() {
        self.sampleNumberLabel.text = "0"
        
        timer?.invalidate()
        self.graphLayer.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        
    }
    
    private func addGraphics(index: Int, previousPoint: CGPoint?, currentPoint: CGPoint) {
        let terrainColor = Terrain.getColor(value: Double(currentPoint.y), maxValue: self.graphLayer.frame.size.height).cgColor
        let shouldGetNewLine:Bool = {
            if previousColor == terrainColor {
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
        lineLayer.strokeColor = terrainColor
        lineLayer.path = line
        
        if shouldGetNewLine {
            self.graphLayer.addSublayer(lineLayer)
        }
        
        previousLineLayer = lineLayer
        previousColor = terrainColor
        previousLine = line
        
        let oval = UIBezierPath(ovalIn: CGRect(x:currentPoint.x, y: currentPoint.y, width: self.ellipseWidth, height: self.ellipseHeight))
        let ovalLayer = CAShapeLayer()
        
        ovalLayer.fillColor = terrainColor
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
        return Terrain(type: terrainType, maxY: Double(max), cameraMax: 0.0)
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

