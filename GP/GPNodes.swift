//
//  GPNodes.swift
//  SwiftGP
//
//  Created by Arvid Bjorkqvist on 2015-09-13.
//  Copyright © 2015 Arvid Bjorkqvist. All rights reserved.
//

import Foundation

enum Direction {
    case East, North, West, South
    case NorthWest, NorthEast, SouthWest, SouthEast
}

class GPNode {
    
    var children = [GPNode!]()
    var parent = [GPNode!]()
    var depth: Int = 0
    
    func numberOfChildren() -> Int {
        return 0
    }
    
    func evaluate(let track: [[Int]], inout position: GPVector2, inout hasMoved: Bool) -> Bool {
        return false
    }
    
    required init() {
    }
    
    func description() -> String {
        return ""
    }
}

class GPAnd : GPNode {
    override func numberOfChildren() -> Int {
        return 2
    }
    
    override func evaluate(let track: [[Int]], inout position: GPVector2, inout hasMoved: Bool) -> Bool {
        return (self.children[0].evaluate(track, position: &position, hasMoved: &hasMoved))
            && (self.children[1].evaluate(track, position: &position, hasMoved: &hasMoved))
    }
    
    override func description() -> String {
        return "(\(self.children[0].description()) && \(self.children[1].description()))"
    }
}

class GPOr : GPNode {
    override func numberOfChildren() -> Int {
        return 2
    }
    
    override func evaluate(let track: [[Int]], inout position: GPVector2, inout hasMoved: Bool) -> Bool {
        return (self.children[0].evaluate(track, position: &position, hasMoved: &hasMoved))
            || (self.children[1].evaluate(track, position: &position, hasMoved: &hasMoved))
    }
    
    override func description() -> String {
        return "!(\(self.children[0].description()) || \(self.children[1].description()))"
    }
}

class GPNot : GPNode {
    override func numberOfChildren() -> Int {
        return 1
    }
    
    override func evaluate(let track: [[Int]], inout position: GPVector2, inout hasMoved: Bool) -> Bool {
        return !(self.children[0].evaluate(track, position: &position, hasMoved: &hasMoved))
    }
    
    override func description() -> String {
        return "!(\(self.children[0].description()))"
    }
}

class GPIf : GPNode {
    override func numberOfChildren() -> Int {
        return 3
    }
    
    override func evaluate(let track: [[Int]], inout position: GPVector2, inout hasMoved: Bool) -> Bool {
        
        return self.children[0].evaluate(track, position: &position, hasMoved: &hasMoved)
            ? self.children[1].evaluate(track, position: &position, hasMoved: &hasMoved)
            : self.children[2].evaluate(track, position: &position, hasMoved: &hasMoved)
    }
    
    override func description() -> String {
        return "((\(self.children[0].description())) ? (\(self.children[1].description())) : (\(self.children[2].description())))"
    }
}

class GPSensor : GPNode {
    
    static let directions = [Direction.North, Direction.NorthEast, Direction.East, Direction.SouthEast, Direction.South, Direction.SouthWest, Direction.West, Direction.NorthWest]
    let direction: Int = Int(arc4random_uniform(UInt32(directions.count)))
    
    override func evaluate(let track: [[Int]], inout position: GPVector2, inout hasMoved: Bool) -> Bool {
        
        var lookAt = GPVector2(x:0, y:0)
        
        switch GPSensor.directions[direction] {
            
        case Direction.North:
            lookAt = GPVector2(x:0, y:1)
        case Direction.NorthEast:
            lookAt = GPVector2(x:1, y:1)
        case Direction.East:
            lookAt = GPVector2(x:1, y:0)
        case Direction.SouthEast:
            lookAt = GPVector2(x:1, y:-1)
        case Direction.South:
            lookAt = GPVector2(x:0, y:-1)
        case Direction.SouthWest:
            lookAt = GPVector2(x:-1, y:-1)
        case Direction.West:
            lookAt = GPVector2(x:-1, y:0)
        case Direction.NorthWest:
            lookAt = GPVector2(x:-1, y:1)
        }
        
        lookAt = position+lookAt
        
        if (lookAt.y >= track.count || lookAt.y < 0) {
            return false
        }
        
        if (lookAt.x >= track[0].count || lookAt.x < 0) {
            return false
        }
        
        return (track[lookAt.y][lookAt.x] == -1)
    }
    
    override func description() -> String {
        return "S[\(GPSensor.directions[self.direction])]"
    }
}

class GPMove : GPNode {
    static let directions = [Direction.North, Direction.East, Direction.South, Direction.West]
    let direction: Int = Int(arc4random_uniform(UInt32(directions.count)))
    
    override func evaluate(let track: [[Int]], inout position: GPVector2, inout hasMoved: Bool) -> Bool {
        
        if (hasMoved) {
            return false
        }
        
        switch GPMove.directions[direction] {
            
        case Direction.North:
            position.y += 1
        case Direction.East:
            position.x += 1
        case Direction.South:
            position.y -= 1
        case Direction.West:
            position.x -= 1
        default: break
        }
        
        hasMoved = true
        return false
    }
    
    override func description() -> String {
        return "M[\(GPSensor.directions[self.direction])]"
    }
}