//
//  StationFetcher.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 23.03.2022.
//

import Foundation

public class StationService: ObservableObject {
    
    @Published var data = [StationModel]()
    
    func load(country: String = "INT", sort: String = "default") {
        
        if(data.count > 0) {
            data.removeAll()
        }
        
        var url = URL(string: "station", relativeTo: Configuration.apiUrl)
        
        url!.appendQueryItem(name:"country", value: country)
        url!.appendQueryItem(name:"sort", value: sort)
        
        URLSession.shared.dataTask(with: url!) {(data,response,error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([StationModel].self, from: d)
                    DispatchQueue.main.async {
                        self.data = decodedLists
                    }
                } else {
                    print("No Data")
                }
            } catch {
                print ("Error")
            }
            
        }.resume()
        
    }
}

