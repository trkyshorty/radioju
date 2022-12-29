//
//  StationListComponent.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 23.03.2022.
//

import SwiftUI
import Kingfisher
import CoreData
import GoogleMobileAds

struct StationListComponent: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("country") var countryCode: String = ""
    
    @StateObject private var radioPlayer = RadioPlayer.instance
    @StateObject private var stationService = RadioPlayer.instance.stationService
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Favorites.timestamp, ascending: true)],
        animation: .default)
    private var favorites: FetchedResults<Favorites>
    
    @State private var searchText = ""
    
    private var genreId : String
    private var favoritesOnly : Bool
    
    private var genreOverlayLimit: Int = 4
    
    init(genreId: String = "", favoritesOnly : Bool = false) {
        self.genreId = genreId
        self.favoritesOnly = favoritesOnly
        
        if UIScreen.main.bounds.size.width <= 320 {
            genreOverlayLimit = 3
        } else if UIScreen.main.bounds.size.width <= 414 {
            genreOverlayLimit = 3
        }
    }
    
    var body: some View {
        ZStack {
            
            if searchResults.count == 0 {
                VStack {
                    ProgressView()
                }
            } else {
               
                List {
                    ForEach(Array(searchResults.enumerated()), id: \.offset) { index, station in
                        if((index == 0 && searchResults.count < 10) || (index > 0 && index.isMultiple(of: 10))) {
                            HStack{
                                Spacer()
                                AdsBannerComponent(size: CGSize(width: 320, height: 50))
                                .frame(width: 320, height: 50, alignment: .center)
                                Spacer()
                            }
                        }
                        HStack(spacing: 8) {
                            KFImage(URL(string: "image/station/" + station.id + ".png", relativeTo: Configuration.cdnUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading) {
                                Text(station.title)
                                    .font(.subheadline)
                                    .padding(.bottom, 1)
                                HStack(spacing: 8) {
                                    ForEach(station.genres.prefix(genreOverlayLimit)) { genre in
                                        Text(String(NSLocalizedString(genre.title, comment: genre.title)))
                                            .padding(.horizontal, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.accentColor)
                                            )
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                }
                            }
                            Spacer()
                            Menu(content: {
                            }) {
                                if (favorites.contains (where: { $0.stationId == station.id }))  {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 25, weight: .light))
                                        .foregroundColor(.orange)
                                } else {
                                    Image(systemName: "star")
                                        .font(.system(size: 25, weight: .light))
                                        .foregroundColor(.orange)
                                }
                            }
                            .onTapGesture {
                                if (favorites.contains (where: { $0.stationId == station.id }))  {
                                    deleteFavoriteStation(stationId: station.id)
                                } else {
                                    addFavoriteStation(stationId: station.id)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            radioPlayer.initPlayer(station)
                            radioPlayer.play()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
            }
        }
        .searchable(text: $searchText, prompt: String(localized: "Search radio stations"))
    }
    
    private func deleteFavoriteStation(stationId : String) {
        withAnimation {
            let fetchRequest = NSFetchRequest<Favorites>(entityName: "Favorites")
            fetchRequest.predicate = NSPredicate(format: "stationId == %@", stationId)
            
            if let result = try? viewContext.fetch(fetchRequest) {
                for object in result {
                    viewContext.delete(object)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addFavoriteStation(stationId : String) {
        withAnimation {
            let newFavorite = Favorites(context: viewContext)
            
            newFavorite.stationId = stationId
            newFavorite.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    var searchResults: [StationModel] {
        var stationList = stationService.data
        
        if(genreId != "" && favoritesOnly == false) {
            stationList = stationList.filter({ $0.genres.contains(where: { $0.id == genreId }) })
        }

        /*if(countryCode != "" && favoritesOnly == false) {
            stationList = stationList.filter({
                $0.countries.contains(where: {
                    $0.code == countryCode ||
                    $0.code == "INT"
                })
            })
        }*/
        
        if(favoritesOnly) {
            let favoriteStationList = favorites.map { $0.stationId }
            stationList = stationList.filter({ favoriteStationList.contains($0.id) })
        }
        
        //stationList = stationList.sorted { $0.title < $1.title }
        
        if searchText.isEmpty {
            return stationList
        } else {
            return stationList.filter { $0.title.contains(searchText) }
        }
    }
}
