//
//  FavoritesView.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI

struct FavoritesView: View {
    var body: some View {
        NavigationView {
            StationListComponent(favoritesOnly: true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.accentColor)
                            Text(String(localized: "Favorites"))
                                .dynamicTypeSize(.medium)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
