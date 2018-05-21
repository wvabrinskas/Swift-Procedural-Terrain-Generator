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
            sampleTextField.text = "\(500)"
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
        }
    }
    
    
    let graphLayer = CAShapeLayer()
    lazy var height = self.view.frame.size.height * 0.7
    var timer:Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        settingsTop.constant = -160.0
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.backgroundColor = .black
        view.backgroundColor = .black
        generateTerrain(samples: 500)
    }
    
    @objc func hideKeyboard() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    
    func clear() {
        self.graphLayer.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        self.graphLayer.removeFromSuperlayer()
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
    
    func generateTerrain(samples: Int) {
        self.clear()
        
        let ellipseWidth:CGFloat = 1.0
        let ellipseHeight:CGFloat = 1.0

        graphLayer.backgroundColor = UIColor(red: 44.0/255.0, green: 48.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor
        graphLayer.frame = CGRect(x: 0, y: self.view.frame.midY - (height / 2.0), width: self.view.frame.size.width, height: height)

        let max = graphLayer.bounds.minY
        let min = graphLayer.bounds.maxY
        
        var previousY = CGFloat(arc4random_uniform(UInt32(min)))
        var previousPoint: UIBezierPath?
        
        let adjustment:UInt32 = UInt32(steepnessTextField.text ?? "\(30)")!
        let spacing:CGFloat = CGFloat(UInt32(sharpnessTextField.text ?? "\(10)")!)
        
        self.scrollView.contentSize = CGSize(width: (CGFloat(samples) * spacing) + 107, height: self.scrollView.contentSize.height)
        self.contentView.layer.addSublayer(graphLayer)
        
        var x = 0
        var previousDirection = 1
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { (timer) in
            if x >= samples {
                DispatchQueue.main.async {
                    self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.contentView.frame.size.height), animated: true)
                }

                timer.invalidate()
            }
            self.sampleNumberLabel.text = "\(x)"

            var newY = previousY
  
            if previousDirection == 0 {
                //down = (+)
                let down = CGFloat(Int.random(lower: UInt32(previousY), upper: UInt32(previousY) + arc4random_uniform(adjustment)))
                newY = down
                if down > min {
                    newY = min
                }
            } else {
                //up = (-)
                let preUp = previousY - CGFloat(arc4random_uniform(adjustment))
                if preUp < 0 {
                    newY = 0
                } else {
                    let up = CGFloat(Int.random(lower:  UInt32(preUp), upper: UInt32(previousY)))
                    newY = up
                    if up < max {
                        newY = max
                    }
                }
            }
            
            let randomDirection = arc4random_uniform(UInt32(self.hillFactorTextField.text ?? "\(10)")!)
            if randomDirection == 0 {
                if previousDirection == 0 {
                    previousDirection = 1
                } else {
                    previousDirection = 0
                }
            }
            
            let oval = UIBezierPath(ovalIn: CGRect(x: CGFloat(x) * spacing, y: self.graphLayer.bounds.maxY - (newY + ellipseHeight), width: ellipseWidth, height: ellipseHeight))
            
            previousY = newY
            
            let line = UIBezierPath()
            if previousPoint != nil {
                line.move(to: CGPoint(x: previousPoint!.currentPoint.x - (0.5 * ellipseWidth), y: previousPoint!.currentPoint.y))
                line.addLine(to: CGPoint(x: oval.currentPoint.x - (0.5 * ellipseWidth), y: oval.currentPoint.y))
            }
            previousPoint = oval
            
            let shapeLayer = CAShapeLayer()
            let lineLayer = CAShapeLayer()
            
            shapeLayer.fillColor = self.getColor(point: oval.currentPoint)
            shapeLayer.strokeColor = UIColor.clear.cgColor
            shapeLayer.path = oval.cgPath
            
            lineLayer.strokeColor = self.getColor(point: oval.currentPoint)
            lineLayer.lineWidth = 5.0
            lineLayer.path = line.cgPath
            lineLayer.lineCap = kCALineCapRound
            
            self.graphLayer.addSublayer(lineLayer)
            self.graphLayer.addSublayer(shapeLayer)
            
            if oval.currentPoint.x >= self.view.frame.maxX - 107 {
                self.graphLayer.frame.size = CGSize(width: self.graphLayer.frame.size.width + (self.view.frame.maxX - 107), height:  self.graphLayer.frame.size.height)
                self.scrollView.setContentOffset(CGPoint(x: oval.currentPoint.x - (self.view.frame.maxX - 107), y: 0), animated: true)
            }
            
            x += 1
        }
        timer.fire()
    }
    
    func noise(size: CGSize, resolution: Int) -> UIImage? {
        let width = Int(size.width)
        let height = Int(size.width)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        let context = UIGraphicsGetCurrentContext()!
        
        var previousAlpha: Double! = Double(arc4random_uniform(10)) / 10.0
        for w in stride(from: 0, through: width, by: resolution) {
            for h in stride(from: 0, through: height, by: resolution) {
                
                if previousAlpha == 0.0 {
                    previousAlpha = 1.0
                }
                
                let randomAlpha = Double(arc4random_uniform(UInt32(previousAlpha * 10))) / 10.0
                previousAlpha = randomAlpha
                
                let color = UIColor.init(white: 1.0, alpha: CGFloat(randomAlpha)).cgColor
                
                context.setFillColor(color)
                context.fill(CGRect(x: w, y: h, width: resolution, height: resolution))
            }
        }
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {

        if settingsTop.constant == 40.0 {
            settingsTop.constant = -160.0
            settingsButton.setImage(#imageLiteral(resourceName: "Hamburger_icon.svg"), for: .normal)
        } else {
            settingsTop.constant = 40.0
            settingsButton.setImage(#imageLiteral(resourceName: "delete-sign"), for: .normal)
        }
        
        UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
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
    
}

