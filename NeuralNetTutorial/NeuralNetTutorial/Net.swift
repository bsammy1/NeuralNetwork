//
//  Net.swift
//  NeuralNetTutorial
//
//  Created by Samat on 11.07.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

enum OutputFunctionType {
    case Sigmoid
    case SoftMax
}

class Net: NSObject {
    var input:[Double] = []
    var layers:[Layer] = []
    var learningRate = 0.5
    var outputFunctionType:OutputFunctionType = .Sigmoid
    
    //initial weights - array of two-dimentional arrays
    init(numberOfLayers:Int, sizesOfLayers:[Int], initialWeights:[[[Double]]], initialBiasWeights:[Double], random:Bool) {
        super.init()
        
        for layerIndex in 0..<numberOfLayers {
            //creating new layer of neurons
            let layer = Layer()
            layers.append(layer)
            layer.net = self
            
            //marking layer as input/output/hidden
            if (layerIndex==0) {
                layer.isInputLayer = true
            } else if (layerIndex==numberOfLayers-1) {
                layer.isOutputLayer = true
            } else {
                layer.isHiddenLayer = true
            }
            
            //create layer connections
            if (!layer.isInputLayer) {
                layer.previousLayer = layers[layerIndex-1]
                layers[layerIndex-1].nextLayer = layer
            }
            
            //adding neurons to new layer
            for neuronIndex in 0..<sizesOfLayers[layerIndex] {
                let neuron = Neuron()
                neuron.layer = layer
                
                //setting weights of neuron if it's not input layer
                if (!layer.isInputLayer) {
                    if (random) {
                        addWeightsToNeuron(random: random, neuron: neuron, inLayer: layer, weights: [[]], neuronIndex:0)
                    } else {
                        addWeightsToNeuron(random: random, neuron: neuron, inLayer: layer, weights: initialWeights[layerIndex-1], neuronIndex:neuronIndex)
                    }
                }
                
                layer.neurons.append(neuron)
            }
        }
        
        addBiases(random: random, initialBiasWeights: initialBiasWeights)
    }
    
    convenience init(numberOfLayers:Int, sizesOfLayers:[Int]) {
        self.init(numberOfLayers: numberOfLayers, sizesOfLayers: sizesOfLayers, initialWeights: [[[]]], initialBiasWeights: [], random: true)
    }
    
    convenience init(numberOfLayers:Int, sizesOfLayers:[Int], initialWeights:[[[Double]]], initialBiasWeights:[Double]) {
        self.init(numberOfLayers: numberOfLayers, sizesOfLayers: sizesOfLayers, initialWeights: initialWeights, initialBiasWeights: initialBiasWeights, random: false)
    }
    
    func addWeightsToNeuron(random:Bool, neuron:Neuron, inLayer layer:Layer, weights:[[Double]], neuronIndex:Int) {
        if (!random) {            
            for weight in weights {
                neuron.weights.append(weight[neuronIndex])
            }
        } else {
            for _ in neuron.layer.previousLayer!.neurons {
                neuron.weights.append(generateRandomWeight())
            }
        }
        
    }
    
    func addBiases(random:Bool, initialBiasWeights:[Double]) {
        for layer in layers {
            let layerIndex = layers.index(of: layer)!
            
            //adding bias
            if (!layer.isOutputLayer) {
                let biasNeuron = Neuron()
                biasNeuron.output = 1
                biasNeuron.isBias = true
                biasNeuron.layer = layer
                
                layer.neurons.append(biasNeuron)
            }

            //adding bias weights
            if (!layer.isInputLayer) {
                for neuron in layer.neurons {
                    if (!random) {
                        neuron.weights.append(initialBiasWeights[layerIndex-1])
                    } else {
                        neuron.weights.append(generateRandomWeight())
                    }
                }
            }
        }
    }
    
    func generateRandomWeight() -> Double {
        let randomNumber = Int(arc4random_uniform(200)) - 100
        
        return Double(randomNumber)/100.0
    }
    
    //backpropagation
    func train(input:[Double], target:[Double]) {
        forwardPropagate(input: input)
        
        //set targets to output layer
        let outputLayer = layers.last!
        for i in 0..<outputLayer.neurons.count {
            outputLayer.neurons[i].target = target[i]
        }
        
        for index in stride(from: layers.count-1, to: 0, by: -1) {
            let layer = layers[index]
            
            for neuron in layer.neurons {
                neuron.applyDeltaRule()
            }
        }
        
        //printing weights for debugging
        for i in 1..<layers.count {
            let layer = layers[i]
            for neuron in layer.neurons {
                print("weights for neuron in layer \(i) - \(neuron.weights)")
            }
        }

        //calculating total error
        var totalError:Double = 0
        for neuron in outputLayer.neurons {
            totalError = totalError + pow((neuron.target-neuron.output), 2)
        }
        totalError = totalError/2
        
        print("total error of network - \(totalError)")
    }
    
    func forwardPropagate(input:[Double]) {
        self.input = input
        
        let inputLayer = layers.first!
        
        //don't take bias neuron
        for i in 0..<inputLayer.neurons.count-1 {
            inputLayer.neurons[i].output = input[i]
        }
        
        for i in 1..<layers.count {
            let layer = layers[i]
            
            for neuron in layer.neurons {
                neuron.calculateOutput()
            }
        }
        
        //printing weights for debugging
        for i in 0..<layers.count {
            let layer = layers[i]
            for neuron in layer.neurons {
                print("output for neuron in layer \(i) - \(neuron.output)")
            }
        }
    }
}
