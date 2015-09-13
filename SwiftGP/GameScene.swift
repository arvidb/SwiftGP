//
//  GameScene.swift
//  SwiftGP
//
//  Created by Arvid Bjorkqvist on 2015-09-11.
//  Copyright (c) 2015 Arvid Bjorkqvist. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, GPProgramDelegate, GPDelegate {
    
    var trail = [CGPoint]()
    let gp = GP()
    let lblFitness = SKLabelNode(text: "")
    let lblProgram = SKLabelNode(text: "")
    let lblStatus = SKLabelNode(text: "")
    
    override func didMoveToView(view: SKView) {
        
        gp.delegate = self
        
        // Build Track
        for (var y=0; y < GPExampleTrack.count; y++) {
        
            for (var x=0; x < GPExampleTrack[y].count; x++) {
                
                let val = GPExampleTrack[y][x]
                var color = SKColor.whiteColor()
                if (val == -1) {
                    color = SKColor.blackColor()
                }
                let brick = SKSpriteNode(color: color, size: CGSizeMake(20, 20))
                brick.position = CGPointMake(CGFloat(400 + x * 20), CGFloat(400 - y * 20))
                self.addChild(brick)
            }
        }
        
        
        lblFitness.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)*0.7)
        self.addChild(lblFitness)
        
        lblProgram.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)*0.8)
        self.addChild(lblProgram)
        
        lblStatus.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)*0.9)
        self.addChild(lblStatus)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.gp.execute(self)
        })
    }
    
    func didStartAlgorithm(gp: GP) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.lblStatus.text = "Calculating..."
        })
    }
    
    func didCompleteAlgorithm(gp: GP) {
        dispatch_async(dispatch_get_main_queue(), {
            self.lblStatus.text = "Complete!"
            self.lblProgram.text = ""
            self.lblFitness.text = ""
        })
    }
    
    func didStartEvaluation(program: GPProgram) {
     
        dispatch_async(dispatch_get_main_queue(), {
            
            self.trail.removeAll()
        })
    }
    
    func didEndEvaluation(program: GPProgram, score: Int) {
        
        if (score > 8) {
            print(score)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.lblProgram.text = "program: \(program.name)"
                self.lblFitness.text = "fitness: \(score)"
                let trailNode = SKNode()
                trailNode.name = "trailNode"
                self.addChild(trailNode)
                for pt in self.trail {
                
                    let trail = SKSpriteNode(color: SKColor.yellowColor(), size: CGSizeMake(20, 20))
                    trail.name = "trail"
                    trail.alpha = 0.4
                    trail.position = CGPointMake(CGFloat(400 + pt.x * 20), CGFloat(400 - pt.y * 20))
                    trailNode.addChild(trail)
                }
                
            })
            
            sleep(2)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let trailNode = self.childNodeWithName("trailNode") {
                    trailNode.removeFromParent()
                }
            })
        }
    }
    
    func didChangePosition(program: GPProgram, position: GPVector2) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.trail.append(CGPointMake(CGFloat(position.x), CGFloat(position.y)))
        })
        //usleep(100000)
    }
}
