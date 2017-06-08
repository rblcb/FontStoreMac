//
//  NSString+InsensitivePrefix.swift
//  Fontstore
//
//  Created by Timothy Armes on 08/06/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Foundation

extension String {
    func caseInsensitiveHasPrefix(_ prefix: String) -> Bool {
        guard let range = range(of: prefix, options:[.caseInsensitive]) else {
            return false
        }
        return range.lowerBound == startIndex
    }
}
