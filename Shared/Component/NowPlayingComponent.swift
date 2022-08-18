//
//  NowPlayingBar.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 15.03.2022.
//

import SwiftUI
import Kingfisher
import MediaPlayer

struct NowPlayingComponent<Content: View>: View {
   private var content: Content
    
    @State private var isPresented = false
    
    @StateObject private var radioPlayer = RadioPlayer.instance
    @State private var nowPlayingInfoCenter = RadioPlayer.instance.nowPlayingInfoCenter
    
    init(content: Content) {
        self.content = content
    }
    
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
        ZStack(alignment: .bottom) {
            self.content
            if radioPlayer.currentStation != nil {
                ZStack {
                    HStack {
                        HStack(){
                            KFImage(URL(string: "image/station/" + radioPlayer.currentStation!.id + ".png", relativeTo: Configuration.cdnUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .scaledToFit()
                                .frame(width: 56, height: 56)
                                .padding(.horizontal)
                            
                            if nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyArtist] != nil {
                                Text((nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyArtist]) as! String).font(.subheadline)
                            } else {
                                Text(radioPlayer.currentStation?.title ?? "").font(.subheadline)
                            }
                            Spacer()
                        }
                        .fullScreenCover(isPresented: $isPresented, content: {
                            NowPlayingView().background(Blur())
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isPresented.toggle()
                        }
                        VStack {
                            if nowPlayingInfoCenter.playbackState == .playing {
                                Button(action: {
                                    radioPlayer.pause()
                                }) {
                                    Image(systemName: "pause.fill")
                                        .font(.system(size: 32, weight: .regular))
                                }.padding(.horizontal)
                            } else if nowPlayingInfoCenter.playbackState == .unknown {
                                Button(action: {
                                    radioPlayer.play()
                                }) {
                                    ProgressView()
                                        .aspectRatio(contentMode: .fit)
                                }.padding(.horizontal)
                                
                            } else if radioPlayer.currentStation?.title != nil {
                                Button(action: {
                                    radioPlayer.play()
                                }) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 32, weight: .regular))
                                }.padding(.horizontal)
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width, height: 65)
                .background(Blur())
            }
        }
    }
}
