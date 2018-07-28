//
//  ExtensionColoredItem.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/27/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit

extension ColoredItem {
    static var possibleColors:[UIColor] {
        return [.red, .blue, .orange, .purple, .cyan, .green, .gray, .brown, .yellow, .white, .black, .magenta]
    }
    
    var color:UIColor? {
        get {
            return self.colorTransformable as? UIColor
        }
        set {
            self.colorTransformable = newValue
        }
    }
}
