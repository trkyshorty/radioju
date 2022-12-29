//
//  SearchView.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI

struct DiscoverView: View {
    @AppStorage("country") var countrySelection: String = ""
    
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
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
