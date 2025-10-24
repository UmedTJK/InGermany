import SwiftUI

struct DeviceFrameView<Content: View>: View {
    private let content: Content
    let device: PreviewDevice
    @Binding var scale: CGFloat
    let fitMode: Bool
    let isLandscape: Bool
    let backgroundStyle: PreviewBackgroundStyle
    
    init(
        device: PreviewDevice,
        scale: Binding<CGFloat>,
        fitMode: Bool = false,
        isLandscape: Bool = false,
        backgroundStyle: PreviewBackgroundStyle = .auto,
        @ViewBuilder content: () -> Content
    ) {
        self.device = device
        self._scale = scale
        self.fitMode = fitMode
        self.isLandscape = isLandscape
        self.backgroundStyle = backgroundStyle
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            let s = device.size
            let baseSize = isLandscape ? CGSize(width: s.height, height: s.width) : s
            
            let effectiveScale: CGFloat = {
                if fitMode {
                    let scaleH = geo.size.height / baseSize.height
                    let scaleW = geo.size.width / baseSize.width
                    return min(scaleH, scaleW) * 0.9
                } else {
                    return scale
                }
            }()
            
            let targetHeight = baseSize.height * effectiveScale
            let targetWidth  = baseSize.width  * effectiveScale
            
            ZStack {
                // внешний фон редактора (НЕ зависит от темы предпросмотра)
                Color(NSColor.controlBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                
                // рамка iPhone
                RoundedRectangle(cornerRadius: 50 * effectiveScale, style: .continuous)
                    .fill(Color.black)
                    .frame(width: targetWidth + 40 * effectiveScale,
                           height: targetHeight + 80 * effectiveScale)
                    .shadow(radius: 8 * effectiveScale)
                
                // экран iPhone
                RoundedRectangle(cornerRadius: 38 * effectiveScale, style: .continuous)
                    .fill(backgroundStyle == .dark ? .black : .white)
                    .frame(width: targetWidth, height: targetHeight)
                    .overlay {
                        let screen = content
                            .frame(width: targetWidth, height: targetHeight)
                            .clipped()
                        
                        // применяем тему ТОЛЬКО к экрану
                        Group {
                            switch backgroundStyle {
                            case .light:
                                screen.environment(\.colorScheme, .light)
                            case .dark:
                                screen.environment(\.colorScheme, .dark)
                            case .auto:
                                screen
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
