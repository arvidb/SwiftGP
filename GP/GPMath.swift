//
//  GPMath.swift
//  SwiftGP
//
//  Created by Arvid Bjorkqvist on 2015-09-13.
//  Copyright © 2015 Arvid Bjorkqvist. All rights reserved.
//

import Foundation

struct GPVector2 {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

func + (lhs: GPVector2, rhs: GPVector2) -> GPVector2 {
    return GPVector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}