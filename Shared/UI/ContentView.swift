//
//  ContentView.swift
//  Shared
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Favorites.timestamp, ascending: true)],
        animation: .default)
    
    private var favorites: FetchedResults<Favorites>
    
    @State private var launchPage = ""
    
    init(launchPage :String) {
        _launchPage = State(initialValue: launchPage)
    }
    
    var body: some View {
        TabView(selection: $launchPage) {
            NowPlayingComponent(content: StationListView())
            .tag("stations")
            .tabItem {
                Label(String(localized: "Stations"), systemImage: "dot.radiowaves.left.and.right")
            }
            
            NowPlayingComponent(content: DiscoverView())
            .tag("discover")
            .tabItem {
                Label(String(localized: "Discover"), systemImage: "magnifyingglass")
            }
      
            if (favorites.count != 0) {
                NowPlayingComponent(content: FavoritesView())
                .tag("favorites")
                .tabItem {
                    Label(String(localized: "Favorites"), systemImage: "star")
                }
            }
            
            SettingsView()
                .tag("settings")
                .tabItem {
                    Label(String(localized: "Settings"), systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(launchPage: "stations")
    }
}


