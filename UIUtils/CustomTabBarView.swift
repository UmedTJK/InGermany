import SwiftUI

struct CustomTabBarView: View {
    @State private var selectedTab: Int = 0
    @Namespace private var animation
    let appContainer: AppContainer
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0: HomeView(appContainer: appContainer)
                case 1: CategoriesView(appContainer: appContainer)
                case 2: SearchView(viewModel: appContainer.makeSearchViewModel())
                case 3: FavoritesView(viewModel: appContainer.makeFavoritesViewModel())
                case 4: SettingsView(viewModel: appContainer.makeSettingsViewModel())
                default: HomeView(appContainer: appContainer)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.bottom)

            HStack {
                tabButton(icon: "house.fill", label: localizationManager.t("tab_home"), index: 0)
                Spacer()
                tabButton(icon: "square.grid.2x2", label: localizationManager.t("tab_categories"), index: 1)
                Spacer()
                tabButton(icon: "magnifyingglass", label: localizationManager.t("tab_search"), index: 2)
                Spacer()
                tabButton(icon: "star.fill", label: localizationManager.t("tab_favorites"), index: 3)
                Spacer()
                tabButton(icon: "gearshape.fill", label: localizationManager.t("tab_settings"), index: 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.thinMaterial) // стеклянный blur
                    .overlay(
                        LinearGradient(
                            colors: [Color.white.opacity(0.25), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func tabButton(icon: String, label: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                if selectedTab == index {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 60, height: 36)
                        .matchedGeometryEffect(id: "tabBackground", in: animation)
                }
                
                Image(systemName: icon)
                    .font(.system(size: selectedTab == index ? 24 : 22, weight: .semibold))
                    .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                    .foregroundColor(selectedTab == index ? .accentColor : .gray)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedTab)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(selectedTab == index ? .accentColor : .gray)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
