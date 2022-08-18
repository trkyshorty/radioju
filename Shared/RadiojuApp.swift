//
//  RadioApp.swift
//  Shared
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI

@main
struct RadiojuApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared
    
    @AppStorage("accentColor") var accentColor: Color = Configuration.accentColor
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("launchPage") var launchPage: String = "stations"
    @AppStorage("country") var country: String = ""
    
    @StateObject private var stationService = RadioPlayer.instance.stationService
    
    init () {
        if(country == "") {
            let availableCountries = ["TR", "AZ", "DE", "US", "DK", "GR", "PL", "IT", "BE", "RU", "UA", "GB", "NL", "FR", "JP"]
            
            if(availableCountries.contains(Locale.current.regionCode!)) {
                country = Locale.current.regionCode!
            } else {
                country = "INT"
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(launchPage: launchPage)
                .accentColor(accentColor)
                .preferredColorScheme(isDarkMode ? .dark : isDarkMode == false ? .light : nil)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear() {
                    stationService.load(country: country)
                }
        }
    }
}
