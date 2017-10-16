//
//  ViewController.swift
//  NeuralNetTutorial
//
//  Created by Samat on 11.07.17.
//  Copyright © 2017 Samat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var net:Net!
    var netView:NetView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //test()
        //let weightsFirstLayer:[[Double]] = [[0.15, 0.25], [0.2, 0.3]]
        let weightsSecondLayer:[[Double]] = [[0.4], [0.45]]

        net = Net(numberOfLayers: 3, sizesOfLayers: [2,2,1])
        
        let frame = CGRect(x: 50, y: 50, width: self.view.bounds.size.width-100, height: self.view.bounds.size.height-100)

        netView = NetView(frame: frame, net: net)
        self.view.addSubview(netView)
        
        self.netView.displayCurrentStateOfNet(duration: 5.0)
        
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 0..<1000 {
                self.net.train(input: [0,1], target: [1])
                self.net.train(input: [1,1], target: [0])
                self.net.train(input: [1,0], target: [1])
                self.net.train(input: [0,0], target: [0])
            }
            
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                self.net.forwardPropagate(input: [0,0])
                self.net.forwardPropagate(input: [1,0])
                self.net.forwardPropagate(input: [0,1])
                self.net.forwardPropagate(input: [1,1])

                self.netView.displayCurrentStateOfNet(duration: 5.0)
            }
        }
        
        for i in 0..<4 {
            let button = UIButton(frame: CGRect(x: 0, y: 0+i*30, width: 30, height: 30))
            
            var text = "0 0"
            
            switch i {
            case 0:
                text = "0 0"
            case 1:
                text = "0 1"
            case 2:
                text = "1 0"
            case 3:
                text = "1 1"
            default:
                text = ""
            }
            
            button.tag = i
            button.setTitle(text, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action:#selector(optionTapped(sender:)), for: .touchUpInside)
            
            self.view.addSubview(button)
        }
    }
    
    func optionTapped(sender:UIButton) {
        print(sender.tag)
        
        var input:[Double] = []
        
        switch sender.tag {
        case 0:
            input = [0,0]
        case 1:
            input = [0,1]
        case 2:
            input = [1,0]
        case 3:
            input = [1,1]
        default:
            input = [0,0]
        }

        self.net.forwardPropagate(input: input)
        
        netView.displayCurrentStateOfNet(duration: 5.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

