//
//  MutableObservableDictionary+Mappabme.swift
//  FontYou
//
//  Created by Timothy Armes on 22/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Foundation
import ObjectMapper
import Bond

public func <- <T: BaseMappable>(left: inout MutableObservableDictionary<String, T>, right: Map) {
    switch right.mappingType {
    case .fromJSON:
        var dict = Dictionary<String, T>()
        dict <- right
        left = MutableObservableDictionary(dict)
    case .toJSON:
        left >>> right
    }
}

public func >>> <T: BaseMappable>(left: MutableObservableDictionary<String, T>, right: Map) {
    if right.mappingType == .toJSON {
        left.dictionary >>> right
    }
}
