//
//  GP.swift
//  SwiftGP
//
//  Created by Arvid Bjorkqvist on 2015-09-11.
//  Copyright © 2015 Arvid Bjorkqvist. All rights reserved.
//

import Foundation

class GP {

    let track = [[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
                [-1, 1, 1, 1, 1, 1, 1, 1, 1,-1],
                [-1, 1, 0, 0, 0, 0, 0, 0, 1,-1],
                [-1, 1, 0, 0, 0, 0, 0, 0, 1,-1],
                [-1, 1, 0, 0, 0, 0, 0, 0, 1,-1],
                [-1, 1, 0, 0, 0, 0, 0, 0, 1,-1],
                [-1, 1, 0, 1, 1, 1, 1, 0, 1,-1],
                [-1, 1, 0, 1,-1,-1, 1, 0, 1,-1],
                [-1, 1, 1, 1,-1,-1, 1, 1, 1,-1],
                [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]]
    
    func randomTrackPos() -> GPVector2 {
        return GPVector2(x:Int(arc4random_uniform(UInt32(track[0].count))), y:Int(arc4random_uniform(UInt32(track.count))))
    }
    
    func execute(delegate: GPProgramDelegate? = nil) {
    
        for (var i=0; i < 5000; i++) {
        
            let gp = GPProgram()
            if (delegate != nil) {
                gp.delegate = delegate
            }
            
            gp.generate()
            //gp.printTree()
            
            // Run the program 10 times with random positions to determine its fitness score
            var maxFitness = 0
            for _ in 0...10 {
            
                var pos = self.randomTrackPos()
                while (track[pos.x][pos.y] != 0) {
                
                    pos = self.randomTrackPos()
                }
                
                let fitness = gp.evaluate(track, position: &pos)
                maxFitness = max(maxFitness, fitness)
            }
            
            //print(maxFitness)
        }
    }
}