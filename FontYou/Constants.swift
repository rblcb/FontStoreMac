//
//  Constants.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//
import Cocoa

let DEV = false

struct Constants {
    struct Dimensions {
        static let arrow = CGSize(width: 25, height: 15)
        static let arrowWindowOverlap: CGFloat = 3
    }

    struct Endpoints {
        static let authEndpoint = DEV ? "http://192.168.55.55:4000/session/desktop" : "https://api.staging.fontstore.com/session/desktop"
        static let webSocketEndpoint = DEV ? "ws://192.168.55.55:4000/socket/websocket" : "wss://api.staging.fontstore.com/socket/websocket"
    }
    
    struct Keys {
        static let fontEncryptionKey = DEV ? "secret" : "lvcypbhupbdmg"
    }
}
