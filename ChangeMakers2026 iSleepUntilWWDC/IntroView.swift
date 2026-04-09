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

struct IntroView: View {
    var body: some View {
        
        ZStack
        {
            
            
            Image("DndMainMenuImage")
                .resizable()
                .scaledToFill().ignoresSafeArea()
            
            Color(red: 0, green: 0, blue: 0, opacity: 0.340)
                .scaledToFit().ignoresSafeArea()
            
            VStack
            {
                Text("Bienvenido a:").foregroundStyle(Color.white)
                
                Text("Change Makers 2026")
                    .font(Font.largeTitle.bold())
                    .shadow(color: .white, radius: 1)
                    .shadow(color: .white, radius: 1)
                    .shadow(color: .white, radius: 1)
                
                ZStack
                {
                    Color(red: 0, green: 0, blue: 0, opacity: 0.3)
                        .frame(width: 390, height: .infinity)
                    
                    
                    
                    VStack
                    {
                        
                        ScrollView
                        {
                            VStack
                            {
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                                
                                    .foregroundStyle(Color.white)
                                    .frame(width: 390, height: .infinity, alignment: .top)
                                    .padding(.top, 40)
                                
                                Spacer()
                            }
                            
                            
                        }
                        
                        
                        //Botones
                        HStack
                        {
                            Button("Click Me") {
                                // Code to execute when tapped
                                print("Button was tapped!")
                            }.padding()
                            
                            Button("Click Me") {
                                // Code to execute when tapped
                                print("Button was tapped!")
                            }.padding()
                            
                        }.padding(10)
                    }
                        
                        
                }
                
                
                
                
                
                
                Spacer()
                
                
                
            }
            .padding()
            
        }
        
    }
}

#Preview {
    IntroView()
}
