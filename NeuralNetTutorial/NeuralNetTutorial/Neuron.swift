//
//  Perceptron.swift
//  NeuralNetTutorial
//
//  Created by Samat on 11.07.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class Neuron: NSObject {
    var inputs:[Double] = [] {
        didSet {
            //adding initial values
            derivarivesOfTotalActivationWRTWeight = []
            derivativesOfTotalActivationOfWRToutputOfPreviousLayer = []
            for _ in inputs {
                derivarivesOfTotalActivationWRTWeight.append(0)
                derivativesOfTotalActivationOfWRToutputOfPreviousLayer.append(0)
            }
        }
    }

    var weights:[Double] = []
    var output:Double = 0
    var derivativeOfTotalErrorWRToutput:Double = 0
    var derivativeOfOutputWRTTotalActivation:Double = 0
    var derivarivesOfTotalActivationWRTWeight:[Double] = []
    var derivativesOfTotalActivationOfWRToutputOfPreviousLayer:[Double] = []
    var layer:Layer = Layer()
    var target:Double = 0
    var isBias:Bool = false
    
    var neuronView:NeuronView?
    
    func calculateOutput() {
        //return 1 if it's bias
        if (isBias) {
            output = 1
            return
        }
        
        //input of this neuron is the outputs of previous layer
        inputs = []
        for neuron in self.layer.previousLayer!.neurons {
            inputs.append(neuron.output)
        }
        
        //calculating total activation
        var totalActivation = 0.0;
        for (index, weight) in weights.enumerated() {

            let inputActivation = weight*inputs[index]
            totalActivation = totalActivation + inputActivation
            
            print("weight - \(weight), input - \(inputs[index]), activation - \(inputActivation)")
        }
        
        print("total net input - \(totalActivation)")
        print("---------------")
        
        var totalOutput = totalActivation
        
        //here we have sigmoid output function
        if (self.layer.net!.outputFunctionType==OutputFunctionType.Sigmoid) {
            totalOutput = 1/(1 + pow(M_E, -totalActivation))
        } else if (self.layer.net!.outputFunctionType==OutputFunctionType.SoftMax) {
            
        }
        
        output = totalOutput
    }
    
    func applyDeltaRule() {
        derivativeOfOutputWRTTotalActivation = output*(1-output)
                
        for (index, input) in inputs.enumerated() {
            derivarivesOfTotalActivationWRTWeight[index] = input
            derivativesOfTotalActivationOfWRToutputOfPreviousLayer[index] = weights[index]
            
            if (self.layer.isOutputLayer) {
                derivativeOfTotalErrorWRToutput = output - target
            } else if (self.layer.isHiddenLayer) {
                derivativeOfTotalErrorWRToutput = 0
                
                let nextLayer = self.layer.nextLayer
                
                let indexOfCurrentNeuronInLayer = self.layer.neurons.index(of: self)!
                
                for neuron in nextLayer!.neurons {
                    derivativeOfTotalErrorWRToutput = derivativeOfTotalErrorWRToutput + neuron.derivativeOfTotalErrorWRToutput*neuron.derivativeOfOutputWRTTotalActivation*neuron.derivativesOfTotalActivationOfWRToutputOfPreviousLayer[indexOfCurrentNeuronInLayer]
                }
            }
            
            let deltaWeight = derivativeOfTotalErrorWRToutput*derivativeOfOutputWRTTotalActivation*derivarivesOfTotalActivationWRTWeight[index]
            
            weights[index] = weights[index] - self.layer.net!.learningRate*deltaWeight
        }
    }
}
