//
//  NowPlayingBar.swift
//  Radio (iOS)
//
//  Created by Türkay TANRIKULU on 14.03.2022.
//

import SwiftUI
import Kingfisher

struct NowPlayingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var radioPlayer = RadioPlayer.instance
    
    struct BackgroundBlurView: UIViewRepresentable {
        func makeUIView(context: Context) -> UIView {
            let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            DispatchQueue.main.async {
                view.superview?.superview?.backgroundColor = .clear
            }
            return view
        }
        func updateUIView(_ uiView: UIView, context: Context) {}
    }

    var body: some View {
        VStack() {
            HStack() {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.down").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 21, height: 21)
                })
                Spacer()
                Text(radioPlayer.currentRadio?.name ?? "").font(.system(size: 14))
                Spacer()
                Button(action: {}, label: {
                    Image(systemName: "ellipsis").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 21, height: 21)
                })
            }
            .padding(16)
         
            VStack() {
                KFImage(URL(string: radioPlayer.currentRadio?.imageUrl ?? ""))
                    .resizable().frame(width: UIScreen.main.bounds.size.width - 75, height: 250)
    
                Divider().padding(8)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Text(radioPlayer.currentRadio?.name ?? "").font(.system(size: 16))
                        Text(radioPlayer.currentRadio?.name ?? "-").font(.system(size: 11))
                        
                    }
                    
                    Spacer()
                }
                .padding(.leading, 16)
                
            }
            Spacer()
        }
        .background(BackgroundBlurView())
    }
}
