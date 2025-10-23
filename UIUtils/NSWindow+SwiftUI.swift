//
//  NSWindow+SwiftUI.swift
//  InGermany
//
//  Created by SUM TJK on 20.10.25.
//

#if os(macOS)
import SwiftUI
import AppKit   // доступен только на macOS

extension View {
    /// Позволяет получить NSWindow, в котором отображается SwiftUI View
    func getHostingWindow(_ callback: @escaping (NSWindow?) -> Void) -> some View {
        self.background(WindowAccessor(onResolve: callback))
    }
}

private struct WindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.onResolve(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
