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
    func didCompleteGeneration(generation: GPGeneration)
    func didCompleteAlgorithm(gp: GP)
}

class GP {

    var delegate: GPDelegate?
    
    func execute(delegate: GPProgramDelegate? = nil) {
    
        self.delegate?.didStartAlgorithm(self)
        
        var lastGen = GPGeneration(name: "Generation0")
        lastGen.generate(delegate)
        lastGen.evaluate()
        
        for i in 0...500 {
         
            self.delegate?.didCompleteGeneration(lastGen)
            
            let genx = GPGeneration(name: "Generation\(i+1)")
            genx.programs = lastGen.topCandidates
            genx.evaluate()
            
            lastGen = genx
        }
        
        self.delegate?.didCompleteAlgorithm(self)
    }
}