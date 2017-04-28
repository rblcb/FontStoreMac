//
//  Data+XOR.swift
//  FontYou
//
//  Created by Timothy Armes on 28/04/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Foundation

public extension Data {
    
    public mutating func xor(key: Data) {
        for i in 0..<self.count {
            self[i] ^= key[i % key.count]
        }
    }
}
