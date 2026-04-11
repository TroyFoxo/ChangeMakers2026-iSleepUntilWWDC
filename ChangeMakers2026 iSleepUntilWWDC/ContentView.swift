import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    
    private var guide = GuideContent(steps: [
        GuideStep(instruction: "Welcome to Danjon"),
        GuideStep(instruction: "Learn how to draw Hiragana characters with ease."),
        GuideStep(instruction: "Explore, complete daily missions, and further learning with activities."),
        GuideStep(instruction: "Practice your learned skills with an interactive chat."),
        GuideStep(instruction: "Ready to start your adventure?")
    ])
    
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
        ZStack {
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
            
            if !hasSeenIntro {
                WalkthroughView(content: guide) {
                    hasSeenIntro = true
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: hasSeenIntro)
    }
}

#Preview {
    ContentView()
}
