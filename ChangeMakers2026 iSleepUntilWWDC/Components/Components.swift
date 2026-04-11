import SwiftUI

struct GlobalBackground: View {
    var body: some View {
        ZStack {
            Image("DndVerticalBg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [Color.black.opacity(0.75), Color.black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .accessibilityHidden(true)
    }
}

struct DiceFaceView: View {
    let value: Int
    let isRolling: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [Theme.dicePrim, Theme.dicePrim],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                //.shadow(color: Theme.primary.opacity(isRolling ? 0.8 : 0.5), radius: 5)
            
            Text("\(value)")
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundStyle(.black)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dice")
        .accessibilityValue("\(value)")
        .accessibilityHint("Double tap to roll.")
    }
}

struct QuestCardView: View {
    let quest: DailyQuest
    let isPrimary: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                action()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(quest.isCompleted ? .green : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.headline)
                        .foregroundStyle(quest.isCompleted ? .secondary : .primary)
                        .strikethrough(quest.isCompleted)
                    
                    Text(quest.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: quest.type.icon)
                    .font(.body)
                    .foregroundStyle(quest.type.color)
            }
            .glassCard(isPrimary: isPrimary, primaryColor: quest.type.color)
            .scaleEffect(quest.isCompleted ? 0.98 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(quest.title)
        .accessibilityValue(quest.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint(quest.description)
    }
}

struct KanaCellView: View {
    let kana: Kana
    
    var body: some View {
        VStack(spacing: 4) {
            Text(kana.character)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(kana.romaji)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassCard(isPrimary: true)
        .opacity(kana.isEmpty ? 0 : 1)
        .accessibilityHidden(kana.isEmpty)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(kana.character)
        .accessibilityValue(kana.romaji)
    }
}
