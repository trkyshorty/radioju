//
//  CategoryFetcher.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 23.03.2022.
//

import Foundation

public class GenreService: ObservableObject {
    
    @Published var data = [GenreModel]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "genre", relativeTo: Configuration.apiUrl)
        
        URLSession.shared.dataTask(with: url!) {(data,response,error) in
            
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([GenreModel].self, from: d)
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


