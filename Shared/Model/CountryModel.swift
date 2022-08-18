//
//  CountryModel.swift
//  Radioju (iOS)
//
//  Created by Türkay TANRIKULU on 26.03.2022.
//

import Foundation

struct CountryModel: Codable, Identifiable {
    public var id: String
    public var title: String
    public var code: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title = "title"
        case code = "code"
    }
}
