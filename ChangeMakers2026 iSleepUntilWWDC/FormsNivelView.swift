//
//  MainMenu.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Alumno on 08/04/26.
//

//
//  ContentView.swift
//  ChangeMakers2026 iSleepUntilWWDC
//
//  Created by Alumno on 08/04/26.
//
import SwiftUI

struct FormsNivelView: View {
    
    @AppStorage("japaneseLevel") private var japaneseSelectedOption: Int = 0
    
    //PAra esconder la view al dar click a siguiente
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Selecciona tu nivel actual de Japonés:")
                .font(.title)
                .multilineTextAlignment(.center)
            
            JapaneseLevelButton(title: "Principiante", isSelected: japaneseSelectedOption == 1) {
                japaneseSelectedOption = 1
            }
            
            JapaneseLevelButton(title: "Basico", isSelected: japaneseSelectedOption == 2) {
                japaneseSelectedOption = 2
            }
            
            JapaneseLevelButton(title: "Avanzado", isSelected: japaneseSelectedOption == 3) {
                japaneseSelectedOption = 3
            }
            
            Text("Tu nivel de Japonés es: \(japaneseSelectedOption)")
            
            Button("Siguiente") {
                print("Nivel guardado: \(japaneseSelectedOption)")
                dismiss()
            }
            .disabled(japaneseSelectedOption == 0)
            
            
        }
        .padding()
    }
}

struct JapaneseLevelButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
        }
    }
}




#Preview {
    FormsNivelView()
}
