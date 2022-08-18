//
//  RadioModel.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import Foundation

struct StationModel: Codable, Identifiable {
    public var id: String
    public var title: String
    public var url: String
    public var genres: [GenreModel]
    public var countries: [CountryModel]
    public var locations: [LocationModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title = "title"
        case url = "url"
        case genres = "genres"
        case countries = "countries"
        case locations = "locations"
    }
}
