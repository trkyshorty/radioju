//
//  StationListView.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI

struct StationListView: View {
    @AppStorage("country") var countrySelection: String = ""
    
    @StateObject private var radioPlayer = RadioPlayer.instance
    @StateObject private var stationService = RadioPlayer.instance.stationService
    @StateObject private var countryService = RadioPlayer.instance.countryService
    
    var body: some View {
        NavigationView {
            StationListComponent()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Spacer()
                            Image(systemName: "dot.radiowaves.left.and.right")
                                .foregroundColor(.accentColor)
                            Text(String(localized: "Radio Stations"))
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
                            .offset(x: 15)
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

struct StationListView_Previews: PreviewProvider {
    static var previews: some View {
        StationListView()
    }
}

