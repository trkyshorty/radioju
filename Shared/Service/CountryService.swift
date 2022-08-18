//
//  CountryService.swift
//  Radioju (iOS)
//
//  Created by Türkay TANRIKULU on 27.03.2022.
//

import Foundation

public class CountryService: ObservableObject {
    
    @Published var data = [CountryModel]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "country", relativeTo: Configuration.apiUrl)
        
        URLSession.shared.dataTask(with: url!) {(data,response,error) in
     
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([CountryModel].self, from: d)
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


