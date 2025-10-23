import SwiftUI

/// Обертка для показа контента в рамке iPhone.
/// Поддерживает масштабирование (scale) и режим Fit-to-Window.
struct DeviceFrameView<Content: View>: View {
    private let content: Content
    private let deviceSize = CGSize(width: 430, height: 932) // базовый iPhone
    @Binding var scale: CGFloat
    let fitMode: Bool
    
    init(scale: Binding<CGFloat>, fitMode: Bool = false, @ViewBuilder content: () -> Content) {
        self._scale = scale
        self.fitMode = fitMode
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            // вычисления лучше оформить в переменные
            let availableHeight = geo.size.height
            let availableWidth = geo.size.width
            
            let effectiveScale: CGFloat = {
                if fitMode {
                    let scaleH = availableHeight / deviceSize.height
                    let scaleW = availableWidth / deviceSize.width
                    return min(scaleH, scaleW) * 0.9
                } else {
                    return scale
                }
            }()
            
            let targetHeight = deviceSize.height * effectiveScale
            let targetWidth = deviceSize.width * effectiveScale
            
            ZStack {
                Color(NSColor.windowBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                
                RoundedRectangle(cornerRadius: 50 * effectiveScale, style: .continuous)
                    .fill(Color.black)
                    .frame(width: targetWidth + 40 * effectiveScale,
                           height: targetHeight + 80 * effectiveScale)
                    .shadow(radius: 8 * effectiveScale)
                
                RoundedRectangle(cornerRadius: 38 * effectiveScale, style: .continuous)
                    .fill(Color.white)
                    .frame(width: targetWidth, height: targetHeight)
                    .overlay(
                        content
                            .frame(width: targetWidth, height: targetHeight)
                            .clipped()
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
