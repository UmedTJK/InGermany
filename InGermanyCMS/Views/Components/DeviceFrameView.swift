//
//  DeviceFrameView.swift
//  InGermany
//
//  Created by SUM TJK on 23.10.25.
//
import SwiftUI

/// A reusable container that simulates an iPhone device frame for previews.
/// This is used in the macOS CMS app to display ArticleRenderer content
/// as if it was running on a real iPhone.
struct DeviceFrameView<Content: View>: View {
    private let content: Content
    
    // Example iPhone 17 Pro Max logical size (points, not pixels).
    private let deviceSize = CGSize(width: 430, height: 932)
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Canvas background (like in Xcode previews)
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            // Device frame
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(Color.black)
                .frame(width: deviceSize.width + 40,
                       height: deviceSize.height + 80)
                .shadow(radius: 12)
            
            // Screen area
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(Color.white)
                .frame(width: deviceSize.width,
                       height: deviceSize.height)
                .overlay {
                    content
                        .frame(width: deviceSize.width,
                               height: deviceSize.height)
                        .clipped()
                }
        }
        .padding()
    }
}

