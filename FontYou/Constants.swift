//
//  Constants.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//
import Cocoa

let DEV = false

#if PROD
let serverUrl = "api.fontstore.com"
let secret = "ugpmfjbtlzpdgrut"
#else
let serverUrl = "api.staging.fontstore.com"
let secret = "lvcypbhupbdmg"
#endif

let devServerUrl = "192.168.55.55:4000"
let devSecret = "secret"

struct Constants {
    struct Dimensions {
        static let arrow = CGSize(width: 25, height: 15)
        static let arrowWindowOverlap: CGFloat = 3
    }
    
    struct Endpoints {
        static let authEndpoint = "https://\(DEV ? devServerUrl : serverUrl)/session/desktop"
        static let webSocketEndpoint = "wss://\(DEV ? devServerUrl : serverUrl)/socket/websocket"
    }
    
    struct Keys {
        static let fontEncryptionKey = DEV ? devSecret : secret
    }
}
