//
//  Schema.swift
//  ShadowPlayBalancer
//
//  Created by Desperado on 01/06/2017.
//  Copyright © 2017 Des. All rights reserved.
//

import Foundation

class Schema {
    private static var _shared: Schema? = nil
    public static var shared: Schema {
        return _shared ?? Schema()
    }
    
    let path = (Plist.shared.getItem(key: "repoPath") as! String) + "/ShadowPlay/"
    
    let props = ["weight", "dash", "chop", "hp", "power", "swiftness", "atk"]
    // "apns", "pairs"
    
    func getFileName(of itemName: String) -> String {
        let header = itemName.components(separatedBy: "_")[0]
        if ["head", "body", "arm", "hand", "thigh", "calf", "foot"].contains(header) {
            return header
        } else {
            return "weapon"
        }
    }
    
    func loadItem(_ itemName: String) -> [String: String] {
        let fileName = getFileName(of: itemName)
        var data = String(readingFrom: path + fileName + ".txt").components(separatedBy: .newlines)
        var schema = data.removeFirst().replacingOccurrences(of: "/", with: "").components(separatedBy: ",").map {return $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        _ = schema.removeFirst()
        let items = data.filter {$0.trimmingCharacters(in: .whitespacesAndNewlines) != ""}.map {$0.components(separatedBy: ",").map {$0.trimmingCharacters(in: .whitespacesAndNewlines)}}
        var dict: [String: String] = [:]
        if var item = (items.filter {$0[0] == itemName}).first {
            item.removeFirst()
            for (i, value) in item.enumerated() {
                let field = schema[i]
                if props.contains(field) {
                    dict[field] = value
                }
            }
        }
        return dict
    }
    
    func saveField(itemName: String, dict: [String: String]) {
        let fileName = getFileName(of: itemName)
        var lines = String(readingFrom: path + fileName + ".txt").components(separatedBy: .newlines)
        let schema = lines[0].replacingOccurrences(of: "/", with: "").components(separatedBy: ",").map {return $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        if let idx = (lines.index { $0.hasPrefix(itemName) }) {
            var line = lines[idx].components(separatedBy: ",")
            for (key, value) in dict {
                if let valIdx = schema.index(of: key) {
                    line[valIdx] = value
                }
            }
            lines[idx] = line.joined(separator: ",")
        }
        let data = lines.joined(separator: "\n")
        do {
            try data.write(toFile: path + fileName + ".txt", atomically: false, encoding: .ascii)
        } catch {
            print("Cannot write data.")
        }
    }
    
    init() {
        Schema._shared = self
    }
}

extension String {
    init(readingFrom path: String) {
        do {
            try self.init(stringLiteral: String(contentsOfFile: path, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            fatalError("Error reading from file.")
        }
    }
}
