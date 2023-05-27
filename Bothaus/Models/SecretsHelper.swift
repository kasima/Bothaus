//
//  File.swift
//  DreamsAI21
//
//  Created by kasima on 5/26/23.
//

import Foundation

class SecretsHelper {
    static func load() -> [String: String]? {
        let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist")
        if let path = url?.path, let data = FileManager.default.contents(atPath: path) {
            do {
                let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
                guard let secrets = plist as? [String: String] else {
                    return nil
                }
                return secrets
            } catch {
                print("Error reading secrets plist file: \(error)")
                return nil
            }
        }
        return nil
    }

    static func load(key: String) -> String? {
        if let secrets = load(), let secret = secrets[key] {
            return secret
        } else {
            return nil
        }
    }
}
