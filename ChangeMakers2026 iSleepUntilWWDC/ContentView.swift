import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor.clear
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            GameView()
                .tabItem { Label("Adventure", systemImage: "map.fill") }
                .tag(1)
            DictionaryView()
                .tabItem { Label("Grimore", systemImage: "book.closed.fill") }
                .tag(2)
            LearningView()
                .tabItem { Label("Learning", systemImage: "character.book.closed.fill") }
                .tag(3)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
