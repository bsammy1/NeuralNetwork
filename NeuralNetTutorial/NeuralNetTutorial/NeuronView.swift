//
//  NeuronView.swift
//  NeuralNetTutorial
//
//  Created by Samat on 14.08.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class NeuronView : UIView {
    let gradientMaskLayer = CAShapeLayer()
    let gradientLayer = CAGradientLayer()
    var neuron:Neuron!
    var outputLabel:UILabel!
    var netView:NetView!
    
    init(frame: CGRect, neuron:Neuron, netView:NetView) {
        super.init(frame: frame)
        
        self.neuron = neuron
        self.netView = netView
        
        self.isOpaque = false;  //makes background transparent
        self.clipsToBounds = false
        
        //let lastView = self.netView.subviews.last

        outputLabel = UILabel(frame: CGRect(x: frame.origin.x-20, y: frame.origin.y-20, width: 60, height: 20))
        outputLabel.text = "0.0"
        self.netView.addSubview(outputLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //fill background with white
        //UIColor.white.setFill()
        //UIRectFill(rect)
        
        if (neuron.isBias) {
            UIColor.blue.setFill()
        } else {
            UIColor(white: 0.0, alpha: 0.2).setFill()
        }
        UIColor.black.setStroke()
        
        //make circle for neuron
        let ovalPath = UIBezierPath(ovalIn: rect)
        ovalPath.fill()
        
        //make stroke for neuron
        let strokeRect = CGRect(x: rect.origin.x+1, y: rect.origin.y+1, width: rect.size.width-2, height: rect.size.height-2)
        let strokePath = UIBezierPath(ovalIn: strokeRect)
        strokePath.stroke()
        
        //create circle layer for masking layer that will be filling the circle from bottom
        gradientMaskLayer.path = ovalPath.cgPath
        layer.mask = gradientMaskLayer
        
        let startPoint = CGPoint(x:0.5, y:0.0)
        let endPoint = CGPoint(x:0.5, y:1.0)
        
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        let fillPercent:CGFloat = 25
        
        let height = self.bounds.size.height*fillPercent/100
        gradientLayer.frame = CGRect(x: 0, y: self.bounds.size.height-height, width: self.bounds.size.width, height: height)
        gradientLayer.colors = getColors(isInitialDirection: true)
        gradientLayer.locations = calculateLocationsFor(height: height)
        
        self.layer.addSublayer(gradientLayer)
        
        let oldPosition = self.gradientLayer.position
        //print("oldPosition \(oldPosition)")
        let oldBounds = self.gradientMaskLayer.bounds
        //print("oldBounds \(oldBounds)")
        let oldMaskPosition = self.gradientMaskLayer.position
        //print("oldMaskPosition \(oldMaskPosition)")
        //print("-----------------")
    }
    
    func animateOutput(output: CGFloat, duration:Double) {
        let height = self.bounds.size.height*output
        
        let oldPosition = self.gradientLayer.position
        //print("oldPosition \(oldPosition)")
        var newPosition = oldPosition
        newPosition.y = self.bounds.size.height - height/2
        //print("newPosition \(newPosition)")
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.fromValue = self.gradientLayer.position
        animation.toValue = newPosition
        self.gradientLayer.position = newPosition
        self.gradientLayer.add(animation, forKey: "position")
        
        let oldGradientBounds = self.gradientLayer.bounds
        //print("oldGradientBounds \(oldGradientBounds)")
        var newGradientBounds = oldGradientBounds
        newGradientBounds.size.height = height
        //print("newGradientBounds \(newGradientBounds)")
        
        let changeGradientBoundsAnimation = CABasicAnimation(keyPath: "bounds")
        changeGradientBoundsAnimation.duration = duration
        changeGradientBoundsAnimation.fromValue = oldGradientBounds
        changeGradientBoundsAnimation.toValue = newGradientBounds
        self.gradientLayer.bounds = newGradientBounds
        self.gradientLayer.add(changeGradientBoundsAnimation, forKey: "bounds")
        
        //changing colors of gradient
        let oldGradientLocations = self.gradientLayer.locations
        print("oldGradientLocations \(String(describing: oldGradientLocations))")
        let newGradientLocations = calculateLocationsFor(height: height)
        
        print("newGradientLocations \(newGradientLocations)")
        
        let changeGradientLocationsAnimation = CABasicAnimation(keyPath: "locations")
        changeGradientLocationsAnimation.duration = duration
        changeGradientLocationsAnimation.fromValue = oldGradientLocations
        changeGradientLocationsAnimation.toValue = newGradientLocations
        self.gradientLayer.locations = newGradientLocations
        self.gradientLayer.add(changeGradientLocationsAnimation, forKey: "locations")
        
        animateGradientColorChanges(isInitialDirection: true)
        
        outputLabel.text = String(format: "%.2f", output)
    }
    
    func animateGradientColorChanges(isInitialDirection:Bool) {
        //changing colors of gradient
        let oldGradientColors = self.gradientLayer.colors
        //print("oldGradientColors \(String(describing: oldGradientColors))")
        let newGradientColors = getColors(isInitialDirection: isInitialDirection)
        //print("newGradientColors \(newGradientColors)")
        
        let changeGradientColorsAnimation = CABasicAnimation(keyPath: "colors")
        changeGradientColorsAnimation.duration = 1.0
        changeGradientColorsAnimation.fromValue = oldGradientColors
        changeGradientColorsAnimation.toValue = newGradientColors
        changeGradientColorsAnimation.fillMode = kCAFillModeForwards
        changeGradientColorsAnimation.isRemovedOnCompletion = false
        self.gradientLayer.colors = newGradientColors
        self.gradientLayer.add(changeGradientColorsAnimation, forKey: "colors")
        
        let when = DispatchTime.now() + 1 // change 1 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            //self.animateGradientColorChanges(isInitialDirection: !isInitialDirection)
        }
    }
    
    func calculateLocationsFor(height:CGFloat) -> [NSNumber] {
        var locations:[NSNumber] = []
        
        let totalHeight = self.bounds.size.height
        
        let heightMultiplier:Double = Double(totalHeight)/Double(height)
        
        for i in 0..<6 {
            let location:Double = heightMultiplier*Double(i)/6+0.07
            locations.append(NSNumber(floatLiteral: location))
        }
        
        return locations
    }
    
    func getColors(isInitialDirection:Bool) -> [CGColor] {
        var colors:[CGColor] = []
        
        var firstColor = UIColor.blue.cgColor
        var secondColor = UIColor.lightGray.cgColor
        
        if (!isInitialDirection) {
            firstColor = UIColor.lightGray.cgColor
            secondColor = UIColor.blue.cgColor
        }
        
        for i in 0..<6 {
            let addingFirstColor = Bool(i%2 as NSNumber)
            
            var addingColor = firstColor
            
            if (!addingFirstColor) {
                addingColor = secondColor
            }
            
            colors.append(addingColor)
        }
        
        return colors
    }
    
    func test() {
        //animateFillChange(toPercent: 100)
    }
}
