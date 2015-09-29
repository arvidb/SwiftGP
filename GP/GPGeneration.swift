//
//  GPGeneration.swift
//  SwiftGP
//
//  Created by Arvid Bjorkqvist on 2015-09-17.
//  Copyright © 2015 Arvid Bjorkqvist. All rights reserved.
//

import Foundation

class GPGeneration {

    var topFitness = 0
    var bestProgram: GPProgram?
    var programs = [GPProgram]()
    var topCandidates = [GPProgram]()
    var name: String = ""
    
    init(name: String) {
        
        self.name = name
    }
    
    func randomTrackPos() -> GPVector2 {
        return GPVector2(x:Int(arc4random_uniform(UInt32(GPExampleTrack[0].count))), y:Int(arc4random_uniform(UInt32(GPExampleTrack.count))))
    }
    
    func generate(delegate: GPProgramDelegate? = nil) {
    
        for (var i=0; i < 5000; i++) {
            
            let gp = GPProgram(name: "Program_\(i)")
            if (delegate != nil) {
                gp.delegate = delegate
            }
            
            gp.generate()
            //gp.printTree()
            
            self.programs.append(gp)
            //print(maxFitness)
        }
    }
    
    func evaluate() {
        
        self.topFitness = 0
        for gp in self.programs {
        
            // Run the program 10 times with random positions to determine its fitness score
            gp.maxFitness = 0
            for _ in 0...10 {
                
                var pos = self.randomTrackPos()
                while (GPExampleTrack[pos.x][pos.y] != 0) {
                    
                    pos = self.randomTrackPos()
                }
                
                gp.maxFitness += gp.evaluate(GPExampleTrack, position: &pos)
            }
            
            if gp.maxFitness > self.topFitness {
            
                self.topFitness = gp.maxFitness
                self.bestProgram = gp
            }
        }
        
        //print(self.topFitness)
        self.findTopCandidates()
    }
    
    func getRandomCandidate() -> GPProgram {
        let randomIndex = Int(arc4random_uniform(UInt32(self.programs.count)))
        return self.programs[randomIndex]
    }
    
    func getRandomFitCandidate() -> GPProgram {
        var prog = getRandomCandidate()
        while (prog.maxFitness <= 0) {
            prog = getRandomCandidate()
        }
        return prog
    }
    
    func findTopCandidates() {
    
        for _ in 0...self.programs.count {
        
            let candidate1 = self.getRandomFitCandidate()
            let candidate2 = self.getRandomFitCandidate()
            let candidate3 = self.getRandomFitCandidate()
            let candidate4 = self.getRandomFitCandidate()
            
            let best1 = candidate1.maxFitness > candidate2.maxFitness ? candidate1 : candidate2
            let best2 = candidate3.maxFitness > candidate4.maxFitness ? candidate3 : candidate4
            
            self.topCandidates.append(best1.crossBreed(best2))
        }
    }
}