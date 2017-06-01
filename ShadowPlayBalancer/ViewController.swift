//
//  ViewController.swift
//  ShadowPlayBalancer
//
//  Created by Desperado on 01/06/2017.
//  Copyright © 2017 Des. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    func getString(title: String, question: String, defaultValue: String) -> String {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaultValue
        
        msg.accessoryView = txt
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return ""
        }
    }
    
    var path: String = ""
    
    private func pathOfName(_ name: String) -> String {
        return path + name
    }

    private func validate(_ path: String) {
        if FileManager.default.fileExists(atPath: "\(path)/ShadowPlay.xcodeproj") {
            self.path = "\(path)/ShadowPlay/"
            print(self.path)
        } else {
            Plist.shared.setItem(key: "repoPath", value: getString(title: "Invalid Path", question: "Please enter the CORRECT path of project folder. It should contain `ShadowPlay.xcodeproj`.", defaultValue: ""))
            validatePath()
        }
    }
    
    private func validatePath() {
        if let path = Plist.shared.getItem(key: "repoPath") as? String {
            validate(path)
        } else {
            Plist.shared.setItem(key: "repoPath", value: getString(title: "Initialization", question: "Please enter the path of project folder containing `ShadowPlay.xcodeproj`.", defaultValue: ""))
            validatePath()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.validatePath()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

