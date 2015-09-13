//
//  GP.swift
//  SwiftGP
//
//  Created by Arvid Bjorkqvist on 2015-09-11.
//  Copyright © 2015 Arvid Bjorkqvist. All rights reserved.
//

import Foundation

protocol GPDelegate {
    func didStartAlgorithm(gp: GP)
    func didCompleteAlgorithm(gp: GP)
}

class GP {

    var delegate: GPDelegate?
    
    func randomTrackPos() -> GPVector2 {
        return GPVector2(x:Int(arc4random_uniform(UInt32(GPExampleTrack[0].count))), y:Int(arc4random_uniform(UInt32(GPExampleTrack.count))))
    }
    
    func execute(delegate: GPProgramDelegate? = nil) {
    
        self.delegate?.didStartAlgorithm(self)
        
        for (var i=0; i < 5000; i++) {
        
            let gp = GPProgram(name: "Program_\(i)")
            if (delegate != nil) {
                gp.delegate = delegate
            }
            
            gp.generate()
            //gp.printTree()
            
            // Run the program 10 times with random positions to determine its fitness score
            var maxFitness = 0
            for _ in 0...10 {
            
                var pos = self.randomTrackPos()
                while (GPExampleTrack[pos.x][pos.y] != 0) {
                
                    pos = self.randomTrackPos()
                }
                
                let fitness = gp.evaluate(GPExampleTrack, position: &pos)
                maxFitness = max(maxFitness, fitness)
            }
            
            //print(maxFitness)
        }
        
        self.delegate?.didCompleteAlgorithm(self)
    }
}