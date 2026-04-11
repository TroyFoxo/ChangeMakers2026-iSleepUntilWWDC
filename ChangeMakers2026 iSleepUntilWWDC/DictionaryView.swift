import SwiftUI

struct DictionaryView: View {
    @State private var viewModel = DictionaryViewModel()
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Grimoire")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Text("Repasa los caracteres descubiertos")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.kanaAlphabet) { kana in
                            Button(action: {
                                viewModel.playSound(for: kana)
                            }) {
                                KanaCellView(kana: kana)
                            }
                            .buttonStyle(.plain)
                            .disabled(kana.isEmpty)
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                GlobalBackground()
            }
            .navigationTitle("Diccionario")
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    DictionaryView()
}
