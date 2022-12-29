//
//  AdsBannerComponent.swift
//  Radioju (iOS)
//
//  Created by Türkay TANRIKULU on 28.12.2022.
//

import SwiftUI
import GoogleMobileAds

struct AdsBannerComponent: UIViewControllerRepresentable  {
    
    init(size: CGSize) {
        self.size = size
    }
    
    var size: CGSize

    func makeUIViewController(context: Context) -> UIViewController {
        let adSize = GADAdSizeFromCGSize(size)
        let view = GADBannerView(adSize: adSize)

        let viewController = UIViewController()
        view.adUnitID = "ca-app-pub-8444491427458003/4670575461"
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: adSize.size)
        view.load(GADRequest())

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
