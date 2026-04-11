import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Campaña Actual")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("El Despertar de los Kana")
                        .font(.title.bold())
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Misiones de Hoy")
                        .font(.title2.bold())
                    
                    Text("Completa tus misiones en orden")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.todayQuests.enumerated()), id: \.element.id) { index, quest in
                            QuestCardView(
                                quest: quest,
                                isPrimary: viewModel.isPrimary(index: index)
                            ) {
                                viewModel.toggleQuest(id: quest.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                GlobalBackground()
            }
            .navigationTitle("Home")
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    HomeView()
}
