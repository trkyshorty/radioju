//
//  DiscoverListComponent.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 24.03.2022.
//
import SwiftUI
import Foundation

struct DiscoverListComponent: View {
    @State private var searchText = ""
    
    @AppStorage("country") var countryCode: String = ""
    
    @StateObject private var genreService = RadioPlayer.instance.genreService
    @StateObject private var stationService = RadioPlayer.instance.stationService
    
    var body: some View {
        ZStack {
            if searchResults.count == 0 {
                VStack {
                    ProgressView()
                }
            } else {
                List {
                    ForEach(searchResults) { genre in
                        NavigationLink(
                            destination:
                                DiscoverStationList(genreId: genre.id)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        HStack {
                                            Image(systemName: "radio")
                                                .font(.system(size: 16, weight: .light))
                                                .foregroundColor(.accentColor)
                                                
                                            Text(String(NSLocalizedString(genre.title, comment: genre.title)))
                                                .foregroundColor(.accentColor)
                                                .dynamicTypeSize(.medium)
                                        }
                                    }
                                }
                        ) {
                            HStack() {
                                Image(systemName: "radio")
                                    .font(.system(size: 25, weight: .light))
                                    .foregroundColor(Color.accentColor)
                                    .padding(.horizontal, 8)
                                Text(String(NSLocalizedString(genre.title, comment: genre.title)))
                                    .font(.subheadline)
                                Spacer()
                                VStack {
                                    let findedStations = stationService.data
                                        .filter({
                                            $0.genres.contains(where: { $0.id == genre.id }) &&
                                            $0.countries.contains(where: {
                                                $0.code == countryCode ||
                                                $0.code == "INT"
                                            })
                                        })
                                    Text(String(findedStations.count))
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
        }
        .searchable(text: $searchText, prompt: String(localized: "Search radio categories"))
    }
    
    struct DiscoverStationList: View {
        private var genreId : String
        
        init(genreId : String) {
            self.genreId = genreId
        }
        
        var body: some View {
            StationListComponent(genreId : genreId)
        }
    }
    
    var searchResults: [GenreModel] {
        var genreList = genreService.data
        
        if(countryCode != "") {
            genreList = genreList.filter({
                $0.countries.contains(where: {
                    $0.code == countryCode ||
                    $0.code == "INT"
                })
            })
        }
        
       //genreList = genreList.sorted {$0.title < $1.title }
        
        if searchText.isEmpty {
            return genreList
        } else {
            return genreList.filter { $0.title.contains(searchText) }
        }
    }
}

