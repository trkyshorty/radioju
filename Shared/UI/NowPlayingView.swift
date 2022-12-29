//
//  NowPlayingView.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 15.03.2022.
//

import SwiftUI
import Kingfisher
import MediaPlayer
import CoreData

extension MPVolumeView {
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}

struct NowPlayingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("accentColor") var accentColor: Color = Configuration.accentColor
    
    @StateObject private var radioPlayer = RadioPlayer.instance
    @State private var nowPlayingInfoCenter = RadioPlayer.instance.nowPlayingInfoCenter
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Favorites.timestamp, ascending: true)],
        animation: .default)
    private var favorites: FetchedResults<Favorites>
    
    @State private var volumeLevel: Float = 0.75
    @State private var lastVolumeLevel: Float = 0.0
    
    struct Blur: UIViewRepresentable {
        var style: UIBlurEffect.Style = .systemChromeMaterial
        
        func makeUIView(context: Context) -> UIVisualEffectView {
            return UIVisualEffectView(effect: UIBlurEffect(style: style))
        }
        
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = UIBlurEffect(style: style)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack() {
                        KFImage(URL(string: "image/station/" + radioPlayer.currentStation!.id + ".png", relativeTo: Configuration.cdnUrl))
                            .resizable()
                            .frame(width: UIScreen.main.bounds.size.width - 75, height: 200)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.bottom)
                        Divider()
                            .padding(.horizontal)
                        HStack() {
                            if nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyArtist] != nil {
                                Text((nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyArtist]) as! String)
                                    .padding(.leading)
                            } else {
                                Text(radioPlayer.currentStation?.title ?? "")
                                    .padding(.leading)
                            }
                            Spacer()
                            Menu(content: {
                            }) {
                                if (favorites.contains (where: { $0.stationId == radioPlayer.currentStation?.id }))  {
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
                                if (favorites.contains (where: { $0.stationId == radioPlayer.currentStation?.id }))  {
                                    deleteFavoriteStation(stationId: radioPlayer.currentStation!.id)
                                } else {
                                    addFavoriteStation(stationId: radioPlayer.currentStation!.id)
                                }
                            }
                        }
                        .padding(.horizontal, 26)
                    }
                    .padding(.vertical, 32)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
               
                Divider()
                    .padding(.horizontal)
                
                if(Configuration.adsEnable) {
                    HStack{
                        Spacer()
                        AdsBannerComponent(size: CGSize(width: 320, height: 50))
                            .frame(width: 320, height: 50, alignment: .center)
                        Spacer()
                    }
                    Divider()
                        .padding(.horizontal)
                }
                
                VStack(alignment: .center) {
                    HStack() {
                        Button(action: {
                            radioPlayer.prevStation()
                        }, label: {
                            Image(systemName: "backward.end")
                                .font(.system(size: 42, weight: .light))
                        }).padding(.horizontal)
                        if nowPlayingInfoCenter.playbackState == .playing {
                            Button(action: {
                                radioPlayer.pause()
                            }, label: {
                                Image(systemName: "pause.circle")
                                    .font(.system(size: 82, weight: .ultraLight))
                            }).padding(.horizontal)
                        } else if radioPlayer.currentStation?.title != nil {
                            Button(action: {
                                radioPlayer.play()
                            }, label: {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 82, weight: .ultraLight))
                            }).padding(.horizontal)
                        }
                        Button(action: {
                            radioPlayer.nextStation()
                        }, label: {
                            Image(systemName: "forward.end")
                                .font(.system(size: 42, weight: .light))
                        }).padding(.horizontal)
                    }
                    HStack() {
                        if volumeLevel != 0.0 {
                            Button(action: {
                                lastVolumeLevel = volumeLevel
                                volumeLevel = 0.0
                                radioPlayer.volume(0.0)
                            }, label: {
                                Image(systemName: "speaker.wave.3")
                                    .font(.system(size: 25))
                            })
                        } else {
                            Button(action: {
                                volumeLevel = 0.75
                                if lastVolumeLevel != 0 {
                                    volumeLevel = lastVolumeLevel
                                }
                                radioPlayer.volume(lastVolumeLevel)
                            }, label: {
                                Image(systemName: "speaker.slash")
                                    .font(.system(size: 25))
                                
                            })
                        }
                        Slider(value: $volumeLevel, in: 0...1,step: 0.0625, onEditingChanged: { data in
                            radioPlayer.volume(volumeLevel)
                        })
                        .padding(.horizontal)
                    }
                }.padding()
            }
            .accentColor(accentColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.accentColor)
                        }
                        Spacer()
                        Text(radioPlayer.currentStation?.title ?? "")
                            .dynamicTypeSize(.medium)
                            .foregroundColor(accentColor)
                        Spacer()
                        Button(action: {
                            radioPlayer.stop()
                        }) {
                            Image(systemName: "power")
                                .foregroundColor(Color.red)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
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
}

struct NowPlayingView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingView()
    }
}
