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

    @IBOutlet weak var settingsButton: UIButton! {
        didSet {
            settingsButton.imageView?.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet weak var settingsLeading: NSLayoutConstraint!
    @IBOutlet weak var settingsTop: NSLayoutConstraint!
    
    @IBOutlet weak var sampleTextField: UITextField! {
        didSet {
            sampleTextField.delegate = self
            sampleTextField.text = "\(501)"
            sampleTextField.keyboardType = .numberPad
        }
    }
    @IBOutlet weak var steepnessTextField: UITextField!  {
        didSet {
            steepnessTextField.delegate = self
            steepnessTextField.text = "\(30)"
            steepnessTextField.keyboardType = .numberPad

        }
    }
    @IBOutlet weak var hillFactorTextField: UITextField!  {
        didSet {
            hillFactorTextField.delegate = self
            hillFactorTextField.text = "\(10)"
            hillFactorTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet weak var sharpnessTextField: UITextField! {
        didSet {
            sharpnessTextField.delegate = self
            sharpnessTextField.text = "\(10)"
            sharpnessTextField.keyboardType = .numberPad
        }
    }
    
    @IBOutlet weak var settingsView: UIView! {
        didSet {
            settingsView.layer.shadowColor = UIColor.black.cgColor
            settingsView.layer.shadowOffset = CGSize(width: 0.0, height: -4.0)
            settingsView.layer.shadowRadius = 10.0
            settingsView.layer.shadowOpacity = 0.8
            settingsView.clipsToBounds = true
            settingsView.layer.cornerRadius = 10.0
            settingsView.alpha = 0.0
        }
    }
    
    
    let graphLayer = CAShapeLayer()
    lazy var height = self.view.frame.size.height * 0.7
    
    var adjustment:UInt32! {
        get {
           return UInt32(steepnessTextField.text ?? "\(30)")!
        }
    }
    var spacing:CGFloat! {
        get {
            return CGFloat(UInt32(sharpnessTextField.text ?? "\(10)")!)
        }
    }
    var timer:Timer!
    
    let ellipseWidth:CGFloat = 1.0
    let ellipseHeight:CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        settingsTop.constant = -160.0
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
        
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
        contentView.backgroundColor = .black
        view.backgroundColor = .black
        generateTerrain(samples: 501)
    }
    
    @objc func hideKeyboard() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    func clear() {
        self.sampleNumberLabel.text = "0"

        timer?.invalidate()
        self.graphLayer.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        self.contentView.subviews.forEach { (subview) in
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
    
    func getColor(point: CGPoint) -> CGColor {
        
        let terrainColors:[CGFloat : CGColor] = [
                             0.2 : UIColor.white.cgColor,
                             0.5 : UIColor.lightGray.cgColor,
                             0.7 : UIColor(red: 179.0/255.0, green: 114.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor,
                             0.85 : UIColor(red: 24.0/255.0, green: 169.0/255.0, blue: 59.0/255.0, alpha: 1.0).cgColor,
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
    
    
    func addGraphics(index: Int, previousPoint: CGPoint?, currentPoint: CGPoint) {
        let oval = UIBezierPath(ovalIn: CGRect(x:currentPoint.x, y: currentPoint.y, width: self.ellipseWidth, height: self.ellipseHeight))
        
        let line = UIBezierPath()
        
        if previousPoint != nil {
            line.move(to: CGPoint(x: previousPoint!.x - (0.5 * self.ellipseWidth), y: previousPoint!.y))
            line.addLine(to: CGPoint(x: currentPoint.x - (0.5 * self.ellipseWidth), y: currentPoint.y))
        }
        
        let shapeLayer = CAShapeLayer()
        let lineLayer = CAShapeLayer()
        let backgroundLineLayer = CAShapeLayer()
        
        shapeLayer.fillColor = self.getColor(point: currentPoint)
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.path = oval.cgPath
        
        lineLayer.strokeColor = self.getColor(point: currentPoint)
        lineLayer.lineWidth = 5.0
        lineLayer.path = line.cgPath
        lineLayer.lineCap = kCALineCapRound
        
        let backgroundLine = UIBezierPath()
        backgroundLine.move(to: CGPoint(x: currentPoint.x, y: 0))
        backgroundLine.addLine(to: CGPoint(x: currentPoint.x, y: self.graphLayer.bounds.maxY))
        
        backgroundLineLayer.strokeColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        backgroundLineLayer.path = backgroundLine.cgPath
        backgroundLineLayer.lineWidth = 1.0
        
        if index == 0 || CGFloat(index).remainder(dividingBy: 10.0) == 0 {
            backgroundLineLayer.lineWidth = 2.0
            
            let graphlabel = UILabel(frame: CGRect(x: currentPoint.x - (index == 0 ? 22 : 25), y: self.contentView.frame.maxY - 35, width: 50, height: 20))
            graphlabel.textAlignment = .center
            graphlabel.textColor = UIColor(white: 1.0, alpha: 0.2)
            graphlabel.backgroundColor = .clear
            graphlabel.font = UIFont.systemFont(ofSize: 10)
            graphlabel.text = "\(index)"
            self.contentView.addSubview(graphlabel)
        }
        
        self.graphLayer.addSublayer(backgroundLineLayer)
        self.graphLayer.addSublayer(lineLayer)
        self.graphLayer.addSublayer(shapeLayer)
        
        if currentPoint.x >= self.view.frame.maxX - 107 {
            self.graphLayer.frame.size = CGSize(width: self.graphLayer.frame.size.width + (self.view.frame.maxX - 107), height:  self.graphLayer.frame.size.height)
            self.scrollView.setContentOffset(CGPoint(x: currentPoint.x - (self.view.frame.maxX - 107), y: 0), animated: true)
        }
        
    }
    
    func generateTerrain(samples: Int) {
        self.clear()
        
        let max = graphLayer.bounds.minY
        let min = graphLayer.bounds.maxY
        
        self.scrollView.contentSize = CGSize(width: (CGFloat(samples) * spacing) + 107, height: self.scrollView.contentSize.height)
        
        var x = 0
        
        let noise = Noise()
        noise.steepness = adjustment
        noise.hillFactor = UInt32(self.hillFactorTextField.text ?? "\(10)")!
        noise.spacing = self.spacing
        
        let points = noise.generate(samples: samples, maxHeight: max, minHeight: min)
        
        var previousPoint: CGPoint?
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { (timer) in
            if points.count == 0 {
                timer.invalidate()
                return
            }
            
            if x >= points.count - 1 {
                DispatchQueue.main.async {
                    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.contentView.frame.size.height), animated: true)
                }
                timer.invalidate()
            }
            
            self.sampleNumberLabel.text = "\(x + 1)"
            
            let current = points[x]
            
            let currentPoint = CGPoint(x: current.x, y: self.graphLayer.bounds.maxY - (current.y + self.ellipseHeight))
            self.addGraphics(index: x, previousPoint: previousPoint, currentPoint: currentPoint)
            
            previousPoint = currentPoint

            x += 1
        }
        timer.fire()
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        var isHidden = false
        
        if settingsTop.constant == 40.0 {
            settingsTop.constant = -160.0
            isHidden = true
            settingsButton.setImage(#imageLiteral(resourceName: "Hamburger_icon.svg"), for: .normal)
        } else {
            isHidden = false
            settingsTop.constant = 40.0
            settingsButton.setImage(#imageLiteral(resourceName: "delete-sign"), for: .normal)
        }
        
        UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.settingsView.alpha = isHidden ? 0.0 : 1.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func startTapped(_ sender: Any) {
       self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.contentView.frame.size.height), animated: true)
        timer.invalidate()
        view.endEditing(true)
        generateTerrain(samples: Int(sampleTextField.text ?? "\(500)")!)
        settingsButtonPressed(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clear()
    }
}

