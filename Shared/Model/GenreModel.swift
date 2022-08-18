//
//  GenreModel.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 22.03.2022.
//

import Foundation

struct GenreModel: Codable, Identifiable {
    public var id: String
    public var title: String
    public var countries: [CountryModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title = "title"
        case countries = "countries"
    }
}
