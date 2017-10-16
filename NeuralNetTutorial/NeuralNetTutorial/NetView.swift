//
//  NetView.swift
//  NeuralNetTutorial
//
//  Created by Samat on 09.08.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class NetView: UIView {
    var net:Net = Net(numberOfLayers: 0, sizesOfLayers: [], initialWeights: [[]], initialBiasWeights: [])
    var connections:[ConnectionView] = []

    var biggestWeight:Double = 0.0
    
    init(frame: CGRect, net:Net) {
        super.init(frame: frame)
        
        self.isOpaque = false  //makes background transparent
        self.clipsToBounds = false
        
        self.backgroundColor = UIColor.black

        self.net = net
        
        let screenWidth = frame.size.width
        let screenHeight = frame.size.height
        
        let margin = CGFloat(20)
        let neuronSize = CGFloat(20)
        
        //putting neurons in place
        for layerIndex in 0..<self.net.layers.count {
            let layer = self.net.layers[layerIndex]
            
            var divider = CGFloat(self.net.layers.count-1)
            let topPart = (screenWidth-2*margin-neuronSize)*CGFloat(layerIndex)
            
            if (self.net.layers.count==1) {
                divider = CGFloat(2)
            }
            
            let xPositionOfNeuron = margin+topPart/divider
            
            for neuronIndex in 0..<layer.neurons.count {
                let neuron = layer.neurons[neuronIndex]
                
                var divider = CGFloat(layer.neurons.count-1)
                var topPart = (screenHeight-2*margin-neuronSize)*CGFloat(neuronIndex)
                
                if (layer.neurons.count==1) {
                    topPart = (screenHeight-2*margin-neuronSize)
                    divider = CGFloat(2)
                }

                let yPositionOfNeuron = margin+topPart/divider

                let neuronView = NeuronView(frame: CGRect(x: xPositionOfNeuron, y: yPositionOfNeuron, width: neuronSize, height: neuronSize), neuron:neuron, netView:self)
                neuronView.netView = self
                
                neuron.neuronView = neuronView
                
                self.addSubview(neuronView)
                
                let when = DispatchTime.now() + 1 // change 1 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Your code with delay
                    neuronView.animateOutput(output: 0, duration: 1.0)
                }
            }
        }
        
        //putting connections in place
        for layerIndex in 1..<self.net.layers.count {
            let layer = self.net.layers[layerIndex]
            
            for currentLayerNeuronIndex in 0..<layer.neurons.count {
                for previousLayerNeuronIndex in 0..<layer.previousLayer!.neurons.count {
                    let currentLayerNeuron = layer.neurons[currentLayerNeuronIndex]
                    let previousLayerNeuron = layer.previousLayer!.neurons[previousLayerNeuronIndex]
                    
                    if (currentLayerNeuron.isBias) {
                        continue
                    }
                    
                    let connectionView = ConnectionView(from: previousLayerNeuron.neuronView!.center, to: currentLayerNeuron.neuronView!.center, fromNeuron: previousLayerNeuron, toNeuron: currentLayerNeuron, netView:self)
                    connectionView.netView = self

                    self.addSubview(connectionView)

                    connections.append(connectionView)
                }
            }
        }
        
        bringLabelsToFront()
    }
    
    func bringLabelsToFront() {
        //putting neurons in front
        for layerIndex in 0..<self.net.layers.count {
            let layer = self.net.layers[layerIndex]
            
            for neuronIndex in 0..<layer.neurons.count {
                let neuron = layer.neurons[neuronIndex]
                
                self.bringSubview(toFront: neuron.neuronView!)
            }
        }
        
        //putting connection weight labels in front
        //displaying weight changes
        for connection in connections {
            self.bringSubview(toFront: connection.weightLabel)
        }
        
        //putting neuron output labels in front
        for layerIndex in 0..<self.net.layers.count {
            let layer = self.net.layers[layerIndex]
            
            for neuronIndex in 0..<layer.neurons.count {
                let neuron = layer.neurons[neuronIndex]
                
                self.bringSubview(toFront: neuron.neuronView!.outputLabel)
            }
        }
    }
    
    func displayCurrentStateOfNet(duration:Double) {
        //displaying neuron outputs
        animateLayersOutput(duration:2 ,layer: self.net.layers.first!)
        
        //calculating weightToLineWidthRatio
        biggestWeight = connections[0].toNeuron!.weights[0]
        //displaying weight changes
        for connection in connections {
            let toNeuron = connection.toNeuron!
            let fromNeuron = connection.fromNeuron!
            let fromNeuronIndex = fromNeuron.layer.neurons.index(of: fromNeuron)!
            
            let weight =  abs(toNeuron.weights[fromNeuronIndex]) 

            if (weight>biggestWeight) {
                biggestWeight = weight
            }
        }
        
        let maximumLineWidth = self.net.layers[0].neurons[0].neuronView!.frame.size.width
        let weightToLineWidthRatio = Double(maximumLineWidth)/biggestWeight
        
        //displaying weight changes
        for connection in connections {
            let toNeuron = connection.toNeuron!
            let fromNeuron = connection.fromNeuron!
            let fromNeuronIndex = fromNeuron.layer.neurons.index(of: fromNeuron)!
            
            let weight = toNeuron.weights[fromNeuronIndex]
            
            print(weight)
            
            connection.weightToLineWidthRatio = weightToLineWidthRatio
            connection.animateWeightChange(newWeight: weight, duration: 0.5)
        }
        
        bringLabelsToFront()
    }
    
    func animateLayersOutput(duration:Double, layer:Layer) {
        if (layer.isInputLayer && Double(layer.neurons.first!.neuronView!.outputLabel.text!)!==0.0) {
            let firstLayerNeuronOutputDuration = 0.0 //duration/4
            
            animateNeuronOutputsInLayer(layer: layer, duration: firstLayerNeuronOutputDuration)
            
            let when = DispatchTime.now() + firstLayerNeuronOutputDuration // change 1 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
                self.animateLayersOutput(duration: duration, layer: layer)
            }

            
            return
        }
        
        animateNeuronOutputsInLayer(layer: layer, duration: duration)
        
        if (!layer.isOutputLayer) {
            let when = DispatchTime.now() + duration // change 1 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
                self.animateLayersOutput(duration:duration, layer: layer.nextLayer!)
            }
            
            //displaying weight changes
            for connection in connections {
                if (layer.neurons.contains(connection.fromNeuron!)) {
                    connection.animateCurrentMovement(duration: duration)
                }
            }
        }
    }
    
    func animateNeuronOutputsInLayer(layer:Layer, duration:Double) {
        for neuronIndex in 0..<layer.neurons.count {
            let neuron = layer.neurons[neuronIndex]
            
            if (layer.neurons.contains(neuron)) {
                neuron.neuronView?.animateOutput(output: CGFloat(neuron.output), duration: duration)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
