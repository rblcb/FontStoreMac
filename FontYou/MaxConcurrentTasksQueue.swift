//
//  MaxConcurrentTasksQueue.swift
//  FontYou
//
//  Created by Timothy Armes on 20/03/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

class MaxConcurrentTasksQueue: NSObject {
    
    private let serialq: DispatchQueue
    private let concurrentq: DispatchQueue
    private let sema: DispatchSemaphore
    
    init(withMaxConcurrency maxConcurrency: Int) {
        serialq = DispatchQueue.init(label: "com.fontstore.serial")
        concurrentq = DispatchQueue.init(label: "concurrent", qos: .background, attributes: .concurrent)
        sema = DispatchSemaphore(value: maxConcurrency)
    }
    
    func enqueue(task: @escaping () -> ()) {
        serialq.async {
            _ = self.sema.wait(timeout: .distantFuture)
            self.concurrentq.async {
                task()
                self.sema.signal()
            }
        }
    }
}
