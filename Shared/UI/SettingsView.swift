//
//  SettingsView.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("accentColor") var accentColor: Color = Configuration.accentColor
    @AppStorage("launchPage") var launchPage: String = "stations"
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(String(localized: "Theme")),
                        footer: Text(String(localized: "Customize the theme according to your preference"))) {
                    VStack(alignment: .leading) {
                        Toggle(String(localized: "Dark Mode"), isOn: $isDarkMode)
                    }
                }
                Section(header: Text(String(localized: "Color")),
                        footer: Text(String(localized: "Change app colors"))) {
                    VStack(alignment: .leading) {
                        ColorPicker(String(localized: "Accent Color"), selection: $accentColor)
                    }
                    VStack(alignment: .leading) {
                        Button(action: {
                            accentColor = Configuration.accentColor
                        }, label: {
                            HStack {
                                Spacer()
                                Text(String(localized: "Reset")).foregroundColor(.red)
                                Spacer()
                            }
                        })
                    }
                }
                Section(header: Text(String(localized: "General")),
                        footer: Text(String(localized: "Change general application settings"))) {
                    VStack(alignment: .leading) {
                        Picker(selection: $launchPage, label: Text(String(localized: "Launch Page"))) {
                            Text(String(localized: "Stations")).tag("stations")
                            Text(String(localized: "Discover")).tag("discover")
                            Text(String(localized: "Favorites")).tag("favorites")
                        }
                    }
                }
                HStack{
                    Spacer()
                    AdsBannerComponent(size: CGSize(width: 320, height: 250))
                    .frame(width: 320, height: 250, alignment: .center)
                    Spacer()
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(.accentColor)
                        Text(String(localized: "Settings"))
                            .dynamicTypeSize(.medium)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
