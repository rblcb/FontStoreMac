//
//  MenuViewController.swift
//  FontYou
//
//  Created by Timothy Armes on 19/01/2017.
//  Copyright © 2017 Arctic Whiteness. All rights reserved.
//

import Cocoa

protocol MenuViewDelegate {
    func goToAccount()
}

class MenuViewController: NSViewController {

    @IBOutlet weak var separatorLineView: NSView!
    
    var delegate: MenuViewDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = StyleKit.primary
        separatorLineView.backgroundColor = NSColor.white
    }
    
    @IBAction func accountPressed(_ sender: Any) {
        delegate?.goToAccount()
    }

    @IBAction func settingsPressed(_ sender: Any) {
    }

    @IBAction func updatePressed(_ sender: Any) {
    }
    
    @IBAction func fontstorePressed(_ sender: Any) {
    }
    
    @IBAction func helpPressed(_ sender: Any) {
    }
    
    @IBAction func aboutPressed(_ sender: Any) {
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
    }
    
    @IBAction func quitPressed(_ sender: Any) {
        NSApplication.shared().terminate(sender);
    }
}
