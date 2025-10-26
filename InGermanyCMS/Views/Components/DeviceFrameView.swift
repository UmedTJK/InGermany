import SwiftUI

struct DeviceFrameView<Content: View>: View {
    private let content: Content
    let device: PreviewDevice
    @Binding var scale: CGFloat
    let fitMode: Bool
    let isLandscape: Bool

    // локальная тема предпросмотра приходит из Environment
    @Environment(\.previewAppearance) private var previewAp

    init(
        device: PreviewDevice,
        scale: Binding<CGFloat>,
        fitMode: Bool = false,
        isLandscape: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.device = device
        self._scale = scale
        self.fitMode = fitMode
        self.isLandscape = isLandscape
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
                // внешний фон редактора (не зависит от темы предпросмотра)
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
                    .fill(Color.black)
                    .frame(width: targetWidth, height: targetHeight)
                    .overlay {
                        let screen = content
                            .frame(width: targetWidth, height: targetHeight)
                            .clipped()
                            .background(previewBackground) // ← фон под контентом

                        if let scheme = previewAp.colorScheme {
                            screen.preferredColorScheme(scheme)
                        } else {
                            screen
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Helpers

    private var previewBackground: Color {
        switch previewAp.background {
        case .plain: return .white
        case .grid:  return Color.gray.opacity(0.2)
        case .paper: return Color(NSColor.windowBackgroundColor)
        }
    }
}
