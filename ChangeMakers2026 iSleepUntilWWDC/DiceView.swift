import SwiftUI

struct DiceView: View {
    @State private var viewModel = DiceViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            
            DiceFaceView(value: viewModel.displayValue, isRolling: viewModel.isRolling)
                .rotationEffect(.degrees(viewModel.shakeDirection))
                .scaleEffect(viewModel.diceScale)
                .animation(
                    viewModel.isRolling
                    ? .linear(duration: 0.08).repeatForever(autoreverses: true)
                    : .default,
                    value: viewModel.shakeDirection
                )
                .onTapGesture {
                    viewModel.rollDice()
                }
            
            Text("Tap the dice to roll")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 20)
                .opacity(viewModel.isRolling ? 0 : 1)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Rolls")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.rollHistory, id: \.self) { value in
                            Text("\(value)")
                                .font(.headline)
                                .frame(width: 40, height: 40)
                                .foregroundStyle(
                                    value == 20 ? .green :
                                    value == 1 ? Theme.primary :
                                    .white
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.cardBackground)
                                )
                        }
                    }
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            GlobalBackground()
        }
    }
}

#Preview {
    DiceView()
}
