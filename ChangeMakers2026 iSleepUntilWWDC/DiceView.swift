import SwiftUI

struct DiceView: View {
    @State private var viewModel = DiceViewModel.shared
    private let diceColumns = [
        GridItem(.adaptive(minimum: 52, maximum: 64), spacing: 10)
    ]
    
    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Text("Choose your dice")
                    .font(.headline)
                    .foregroundStyle(.white)

                LazyVGrid(columns: diceColumns, alignment: .center, spacing: 10) {
                    ForEach(viewModel.availableDiceSides, id: \.self) { sides in
                        Button {
                            viewModel.selectDice(sides: sides)
                        } label: {
                            Text("d\(sides)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(
                                            viewModel.selectedSides == sides
                                                ? Theme.primary.opacity(0.75)
                                                : Theme.cardBackground
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            viewModel.selectedSides == sides
                                                ? Theme.primary
                                                : Color.white.opacity(0.1),
                                            lineWidth: 1.5
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Select d\(sides)")
                        .accessibilityValue(viewModel.selectedSides == sides ? "Selected" : "Not selected")
                    }
                }
                .frame(maxWidth: 320)
            }
            .padding(.bottom, 28)
            
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
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Rolls the selected die.")

            Text("d\(viewModel.selectedSides)")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.primary)
                .padding(.top, 16)
            
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
                                    value == viewModel.selectedSides ? .green :
                                    value == 1 ? Theme.primary :
                                    .white
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Theme.cardBackground)
                                )
                                .accessibilityLabel("Previous roll")
                                .accessibilityValue("\(value)")
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
