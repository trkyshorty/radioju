//
//  SearchView.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI

struct DiscoverView: View {
    @AppStorage("country") var countrySelection: String = ""
    @AppStorage("genreSort") var genreSortSelection: String = ""
    
    @StateObject private var radioPlayer = RadioPlayer.instance
    @StateObject private var stationService = RadioPlayer.instance.stationService
    @StateObject private var countryService = RadioPlayer.instance.countryService
    
    var body: some View {
        NavigationView {
            DiscoverListComponent()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Menu(content: {
                                Picker("Sort", selection: $genreSortSelection.onChange(sortChanged)) {
                                    Text(String(NSLocalizedString("Default", comment: "Default"))).tag("default")
                                    Text(String(NSLocalizedString("A-Z", comment: "A-Z"))).tag("asc")
                                    Text(String(NSLocalizedString("Z-A", comment: "Z-A"))).tag("desc")
                                }
                            },
                            label: {
                                Label("Sort", systemImage: "arrow.up.and.down.text.horizontal")
                            })
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.accentColor)
                            Text(String(localized: "Discover"))
                                .dynamicTypeSize(.medium)
                                .foregroundColor(.accentColor)
                            Spacer()
                            Menu(content: {
                                Picker("Country", selection: $countrySelection.onChange(countryChanged)) {
                                    ForEach(countryService.data) { country in
                                        Text(String(NSLocalizedString(country.title, comment: country.title))).tag(country.code)
                                    }
                                }
                            },
                            label: {
                                Label("Country", systemImage: "globe.badge.chevron.backward")
                            })
                        }
                        .ignoresSafeArea()
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    func countryChanged(to value: String) {
        stationService.load(country: countrySelection)
    }
    
    func sortChanged(to value: String) {
        //stationService.load(country: countrySelection)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
