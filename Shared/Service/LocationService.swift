//
//  LocationService.swift
//  Radioju (iOS)
//
//  Created by Türkay TANRIKULU on 27.03.2022.
//

import Foundation

public class LocationService: ObservableObject {
    
    @Published var data = [LocationModel]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "location", relativeTo: Configuration.apiUrl)
        
        URLSession.shared.dataTask(with: url!) {(data,response,error) in
    
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([LocationModel].self, from: d)
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


