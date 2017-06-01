//
//  ViewController.swift
//  ShadowPlayBalancer
//
//  Created by Desperado on 01/06/2017.
//  Copyright © 2017 Des. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var itemNameField: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var specsView: NSBox!
    
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
    
    var controlsDict: [String: NSTextField] = [:]
    
    private func pathOfName(_ name: String) -> String {
        return path + name
    }

    private func validate(_ path: String) {
        if FileManager.default.fileExists(atPath: "\(path)/ShadowPlay.xcodeproj") {
            self.path = "\(path)/ShadowPlay/"
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
    
    private func UISetup() {
        imageView.layer?.borderWidth = 1
        imageView.layer?.borderColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.validatePath()
        self.UISetup()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func openProjFolder(_ sender: Any) {
        NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: path)
    }
    
    private func setControls(dict: [String: String]) {
        self.specsView.contentView?.subviews = []
        self.controlsDict = [:]
        var y = self.specsView.contentView!.frame.height - 10
        for (key, value) in dict {
            y -= 12
            let label = NSTextField(labelWithString: key + ":")
            label.frame = NSRect(x: 0, y: y, width: 50, height: 20)
            self.specsView.contentView?.addSubview(label)
            label.isEditable = false
            let valueField = NSTextField(frame: NSRect(x: 50, y: y, width: 100, height: 20))
            self.specsView.contentView?.addSubview(valueField)
            self.controlsDict[key] = valueField
            valueField.stringValue = value
            valueField.isEditable = true
            y -= 12
        }
    }
    
    @IBAction func load(_ sender: Any) {
        if let image = NSImage(byReferencingFile: pathOfName(itemNameField.stringValue) + ".png") {
            let scale = (250 / max(image.size.width, image.size.height))
            image.size = NSSize(width: scale * image.size.width, height: scale * image.size.height)
            imageView.image = image
            self.setControls(dict: Schema.shared.loadItem(itemNameField.stringValue))
        }
    }

    @IBAction func save(_ sender: Any) {
        var dict: [String: String] = [:]
        for (key, value) in controlsDict {
            dict[key] = value.stringValue
        }
        Schema.shared.saveField(itemName: itemNameField.stringValue, dict: dict)
        load(self)
    }

}

