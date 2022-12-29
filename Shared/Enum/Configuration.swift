//
//  Configuration.swift
//  Radioju (iOS)
//
//  Created by Türkay TANRIKULU on 27.03.2022.
//

import Foundation
import SwiftUI

enum Configuration {
    static var cdnUrl: URL {
#if DEBUG
        return try! URL(string: "http://" + Configuration.value(for: "cdnUrl"))!
#else
        return try! URL(string: "https://" + Configuration.value(for: "cdnUrl"))!
#endif
    }
    
    static var apiUrl: URL {
#if DEBUG
        return try! URL(string: "http://" + Configuration.value(for: "apiUrl"))!
#else
        return try! URL(string: "https://" + Configuration.value(for: "apiUrl"))!
#endif
    }
    
    static var accentColor: Color = Color(rawValue: 0xFF2D55)!
    
    static var adsEnable: Bool {
        return try! Configuration.value(for: "adsEnable") == "YES" ? true : false
    }
    
    
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}
