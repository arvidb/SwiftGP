//
//  GP.swift
//  SwiftGP
//
//  Created by Arvid Bjorkqvist on 2015-09-11.
//  Copyright © 2015 Arvid Bjorkqvist. All rights reserved.
//

import Foundation

protocol GPProgramDelegate {
    func didStartEvaluation(program: GPProgram)
    func didEndEvaluation(program: GPProgram, score: Int)
    func didChangePosition(program: GPProgram, position: GPVector2)
}

class GPProgram {

    static let MAX_DEPTH = 4
    private var rootNode: GPNode? = nil
    
    var maxFitness = 0
    
    var name = "Unknown"
    var delegate: GPProgramDelegate?
    
    static let availableNodes: [GPNode.Type] = [GPAnd.self, GPOr.self, GPNot.self, GPIf.self, GPMove.self, GPSensor.self]
    static let endNodes: [GPNode.Type] = [GPMove.self, GPSensor.self]
    
    init(name: String) {
    
        self.name = name
    }
    
    func randomNode(available: [GPNode.Type] = availableNodes, depth: Int) -> GPNode {
        
        let randomIndex = Int(arc4random_uniform(UInt32(available.count)))
        let type = available[randomIndex]
        if (depth > GPProgram.MAX_DEPTH && !(type is GPMove.Type || type is GPSensor.Type) ) {
        
            return randomNode(GPProgram.endNodes, depth: depth)
        }
        
        return available[randomIndex].init()
    }
    
    func generate() {
    
        self.rootNode = randomNode(depth: 0)
        generateChildNodes(self.rootNode!)
    }
    
    func evaluate(var track: [[Int]], inout position: GPVector2) -> Int {
    
        delegate?.didStartEvaluation(self)
        delegate?.didChangePosition(self, position: position)
        
        var fitness = 0
        for _ in 0...60 {
        
            var hasMoved = false
            var gotPoint = self.rootNode!.evaluate(track, position: &position, hasMoved: &hasMoved)
            
            if (hasMoved) {
                delegate?.didChangePosition(self, position: position)
            } else {
            
                gotPoint = false
            }
            
            if (track[position.y][position.x] == -1) {
                break
            }
            
            if (gotPoint && track[position.y][position.x] == 1) {
                
                // Disable this point so we can´t collect it again
                track[position.y][position.x] = 0
            }
            else {
            
                gotPoint = false
            }
            
            fitness += gotPoint ? 1 : 0
        }
        
        delegate?.didEndEvaluation(self, score: fitness)
        return fitness
    }
    
    func clone() -> GPProgram {
    
        let clone = GPProgram(name: self.name)
        clone.delegate = self.delegate
        clone.rootNode = self.rootNode!.clone()
        
        return clone
    }
    
    func crossBreed(otherProgram: GPProgram) -> GPProgram {
    
        let newProgramA = self.clone()
        let newProgramB = otherProgram.clone()
        
        var flatList = self.buildFlatChildList(newProgramA.rootNode!)
        
        let randomIndex = Int(arc4random_uniform(UInt32(flatList.count)))
        let randomChild = flatList[randomIndex]
        
        let flatList2 = self.buildFlatChildList(newProgramB.rootNode!)
        
        let randomIndex2 = Int(arc4random_uniform(UInt32(flatList2.count)))
        let randomChild2 = flatList2[randomIndex2]
        
        if randomChild.children.count > 0 {
            let i = Int(arc4random_uniform(UInt32(randomChild.children.count)))
            randomChild2.parent = randomChild.children[i].parent
            randomChild.children[i] = randomChild2
        }
        else if let parent = randomChild.parent {
            let i = Int(arc4random_uniform(UInt32(parent.children.count)))
            randomChild2.parent = parent.children[i].parent
            parent.children[i] = randomChild2
        }
        else {
        
            newProgramA.rootNode = randomChild2
            randomChild2.parent = nil
        }
        
        return newProgramA
    }
    
    func buildFlatChildList(node: GPNode) -> [GPNode] {
    
        var children = [GPNode]()
        children.append(node)
        for child in node.children {
            
            children.appendContentsOf(buildFlatChildList(child))
        }
        
        return children
    }
    
    func printTree() {
    
        printChildren(self.rootNode!)
    }
    
    private func printChildren(node: GPNode) {
    
        print(node.description(), terminator:"")
        for child in node.children {
        
            printChildren(child)
        }
    }
    
    func generateChildNodes(node: GPNode) {
    
        for (var n=0; n < node.numberOfChildren(); n++) {
            let child = randomNode(depth: node.depth)
            node.children.append(child)
            child.parent = node
            child.depth = node.depth+1
            generateChildNodes(child)
        }
    }
}