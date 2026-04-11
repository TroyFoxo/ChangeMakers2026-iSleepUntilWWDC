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

struct GameView: View {
    
    @State private var showNextView = false
    
    //Para ocultar el NPC y el dialogo de la campaña
    @State private var isVisible = true
    
    //Para guardar la prompt del usuario en un avariable (storedUserPrompt)
    @State private var userPrompt = ""
    @State private var storedUserPrompt = ""
    
    @State var NPCDialogue = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    var body: some View {
        
        
        

            VStack
            {
                
                if isVisible{
                    
                    
                    //NPC Image, Dialogue and Hide Button :3
                    VStack
                    {
                        
                        //NPC
                        ZStack
                        {
                            
                            Image("ForestTrees")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 300)
                                .opacity(0.4)
                            
                            Image("HouseBG")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth:300)
                                .opacity(0.4)
                            
                            Image("DndPotionLadySmaller")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 300)
                            
                        }.frame(maxWidth: 380, maxHeight: 200, alignment: .bottom)
                            .padding(.bottom, 40)
                            .glassCard(isPrimary: true)
                        
                        
                        //NPC chat and hide button
                        ScrollView
                        {
                            VStack
                            {
                                
                                
                                Text(NPCDialogue)
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: 320, maxHeight: .infinity, alignment: .bottom)
                                    .padding(.vertical)

                            }
                            
                        }.frame(maxWidth: 380, maxHeight: 200, alignment: .bottom).glassCard(isPrimary: true)
                        
                    }
                       
                    Spacer()
                }//Condicional para mostrar Dialogo de NPC e imagen
                
                else
                {
                    Spacer()
                }
                

                //Chat de jugador
                
                HStack
                {
                    TextField("¿Que harás ahora?:", text: $userPrompt)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .frame(height:50)
                                
                    
                    Button("Send") {
                        storedUserPrompt = userPrompt
                        print(storedUserPrompt)
                    }.glassCard(isPrimary: true).foregroundStyle(  .white)
                    .frame(height:50)
                    
                }.padding()
                
                
                
                Button("Mostrar Mapa") {
                    isVisible.toggle()
                }.foregroundStyle(  .white)
                
            }//VStack
            //Imagen de fondo como atributo del vstack
            .frame(maxWidth: 400, maxHeight: .infinity)
            .background {
                ZStack {
                    Image("DndMapPlaceholder")
                        .resizable()
                        .scaledToFill()
                        
                    
                    if isVisible{Color.black.opacity(0.54)}
                    else{Color.black.opacity(00)}
                }
                .ignoresSafeArea()
            }
            
            
        }
        
    }


#Preview {
    GameView()
}
