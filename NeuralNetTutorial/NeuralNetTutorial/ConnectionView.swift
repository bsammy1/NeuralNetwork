//
//  ConnectionView.swift
//  NeuralNetTutorial
//
//  Created by Samat on 14.08.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class ConnectionView: UIView {
    private var isUp:Bool = false
    var isHorizontal:Bool = false
    
    let lineLayer = CAShapeLayer()
    let linePath = UIBezierPath()

    var weight:Double = 0
    var fromNeuron:Neuron?
    var toNeuron:Neuron?
    
    var lineWidth:CGFloat = 20
    
    var weightLabel:UILabel!
    var netView:NetView!
    
    var weightToLineWidthRatio:Double = 20
    
    init(from: CGPoint, to: CGPoint, fromNeuron:Neuron, toNeuron:Neuron, netView:NetView) {
        self.fromNeuron = fromNeuron
        self.toNeuron = toNeuron
        self.netView = netView
        
        var minimumY = from.y
        var maximumY = to.y
        isUp = false
        
        if (from.y>to.y) {
            minimumY = to.y
            maximumY = from.y
            isUp = true
        }
        
        var height = maximumY - minimumY
        let width = to.x-from.x
        
        if (from.y==to.y) {
            minimumY=minimumY-lineWidth/2
            height = lineWidth
            isHorizontal = true
        }
        
        let frame = CGRect(x: from.x, y: minimumY, width: width, height: height)
        //let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        print("from - \(from), to - \(to)")
        
        super.init(frame: frame)
        
        self.isOpaque = false  //makes background transparent
        self.clipsToBounds = false
        
        //let lastView = self.netView.subviews.last
        
        weightLabel = UILabel(frame: frame)
        self.netView.addSubview(weightLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Drawing code
        //fill background with white
        //UIColor.white.setFill()
        //UIRectFill(rect)
        
        var fromY = rect.origin.y
        var toY = rect.size.height
        
        if (isUp) {
            fromY = rect.size.height
            toY = rect.origin.y
        }
        
        if (isHorizontal) {
            fromY = rect.origin.y+rect.size.height/2
            toY = fromY
        }
        
        linePath.move(to: CGPoint(x: rect.origin.x, y: fromY))
        linePath.addLine(to: CGPoint(x: rect.size.width, y: toY))
        
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = UIColor.green.cgColor
        
        self.layer.addSublayer(lineLayer)
    }
    
    func animateWeightChange(newWeight:Double, duration:Double) {
        let isPositive = (newWeight>=0)
        
        let sameSign = weight * newWeight > 0
        
        let oldLineWidth = self.lineLayer.lineWidth
        let newLineWidth = abs(newWeight*weightToLineWidthRatio)
        
        lineWidth = CGFloat(newLineWidth)
        
        let changeLineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        changeLineWidthAnimation.duration = duration
        changeLineWidthAnimation.fromValue = oldLineWidth
        changeLineWidthAnimation.toValue = CGFloat(newLineWidth)
        self.lineLayer.lineWidth = CGFloat(newLineWidth)
        self.lineLayer.add(changeLineWidthAnimation, forKey: "lineWidth")
        
        if (!sameSign) {
            var newColor = UIColor.green.cgColor
            
            if (!isPositive) {
                newColor = UIColor.darkGray.cgColor
            }
            
            let oldColor = self.lineLayer.strokeColor
            
            let changeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
            changeColorAnimation.duration = duration
            changeColorAnimation.fromValue = oldColor
            changeColorAnimation.toValue = newColor
            self.lineLayer.strokeColor = newColor
            self.lineLayer.add(changeColorAnimation, forKey: "strokeColor")
        }
        
        weight = newWeight
        
        weightLabel.text = String(format: "%.2f", newWeight)
    }
    
    func animateCurrentMovement(duration:Double) {
        var fromY = self.bounds.origin.y
        
        if (isUp) {
            fromY = self.bounds.size.height
        }
        
        let maximumCurrentCircleSize:CGFloat = 20
        
        let currentWeightToMaxWeightRatio:CGFloat = CGFloat(self.weight/netView.biggestWeight)
        
        let currentCircleSize = maximumCurrentCircleSize /** CGFloat(self.fromNeuron!.output)*/ * CGFloat(currentWeightToMaxWeightRatio)
        
        let currentView = UIView(frame: CGRect(x: 0, y: fromY, width: currentCircleSize, height: currentCircleSize))
        currentView.backgroundColor = UIColor.red
        currentView.layer.cornerRadius = currentCircleSize/2
        
        self.addSubview(currentView)
        
        let movementAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
        //print(lineLayer.path)
        
        movementAnimation.path = linePath.cgPath
        movementAnimation.duration = duration
        
        currentView.layer.add(movementAnimation, forKey: "animate position along path")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            currentView.removeFromSuperview()
        }
    }
    
    func test() {
        print("hello world")
        animateWeightChange(newWeight: -20, duration: 1.0)
    }
}
