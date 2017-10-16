//
//  Layer.swift
//  NeuralNetTutorial
//
//  Created by Samat on 08.08.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class Layer: NSObject {
    var nextLayer:Layer?
    var previousLayer:Layer?
    var neurons:[Neuron] = []
    var isInputLayer:Bool = false
    var isOutputLayer:Bool = false
    var isHiddenLayer:Bool = false
    var net:Net?
}
