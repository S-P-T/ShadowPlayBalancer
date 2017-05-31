//
//  StorageManager.swift
//  ShadowPlayBalancer
//
//  Created by Desperado on 01/06/2017.
//  Copyright © 2017 Des. All rights reserved.
//

import Foundation

class Plist {
    
    private static var _shared: Plist? = nil
    public static var shared: Plist {
        return _shared ?? Plist()!
    }
    
    enum PlistError: Error {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    var sourcePath: String? {
        guard let path = Bundle.main.path(forResource: "meta", ofType: "plist") else { return .none }
        return path
    }
    
    var destPath: String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("meta.plist")
    }
    
    init?() {
        let fileManager = FileManager.default
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else { return nil }
        if !fileManager.fileExists(atPath: destination) {
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    /// Create NSDictionary from stored Plist file.
    func getValuesInPlistFile() -> NSDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    /// Create NSMutableDictionary from stored Plist file.
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func getItem(key: String) -> Any? {
        if let dict = getValuesInPlistFile() {
            return dict.value(forKey: key)
        }
        return nil
    }
    
    func setItem(key: String, value: String) {
        if let dict = getMutablePlistFile() {
            dict.setValue(value, forKey: key)
            do {
                try self.addValuesToPlistFile(dictionary: dict as NSDictionary)
            } catch {
                print(error)
            }
        }
    }
    
    func addValuesToPlistFile(dictionary:NSDictionary) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !dictionary.write(toFile: destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
}
