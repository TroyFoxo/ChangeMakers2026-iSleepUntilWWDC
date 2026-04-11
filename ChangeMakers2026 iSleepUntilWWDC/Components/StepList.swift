import SwiftUI

struct GuideStep: Identifiable {
    let id = UUID()
    var instruction: String
}

struct GuideContent {
    var steps: [GuideStep]
}

struct WalkthroughView: View {
    let content: GuideContent
    var onFinish: () -> Void
    
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            Image("DndVerticalBg2")
                .resizable()
                .ignoresSafeArea()
            
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { previousStep() }
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { advanceStep() }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Text("\(currentIndex + 1)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
                
                Spacer()
                
                Text(content.steps[currentIndex].instruction)
                    .font(.system(size: 34, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .id(currentIndex)
                    .animation(.easeInOut, value: currentIndex)
                
                Spacer()
                
                HStack {
                    if currentIndex > 0 {
                        Text("<")
                    } else {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text(currentIndex < content.steps.count - 1 ? ">" : "Home")
                        .onTapGesture {
                            if currentIndex < content.steps.count - 1 {
                                advanceStep()
                            } else {
                                onFinish()
                            }
                        }
                }
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func advanceStep() {
        if currentIndex < content.steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
        } else {
            onFinish()
        }
    }
    
    private func previousStep() {
        if currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex -= 1
            }
        }
    }
}
