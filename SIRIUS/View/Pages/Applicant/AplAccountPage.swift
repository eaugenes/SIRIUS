//
//  AplAccountPage.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct AplAccountPage: View {
    
    @State private var logInScreen = false
    @State private var editAccountScreen = false
    
    var body: some View {
        NavigationStack{
            VStack{
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                
                Text("Cherry Mauren Buendia")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("@cherrymauren")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            
            
            VStack{
                VStack{
                    HStack{
                        Text("Date of Birth")
                        
                        Spacer()
                        
                        Text("January 1, 2000")
                    }
                    
                    Divider()
                    
                    HStack{
                        Text("Location")
                        
                        Spacer()
                        
                        Text("Lucena City")
                    }
                    
                    Divider()
                    
                    HStack{
                        Text("Contact Number")
                        
                        Spacer()
                        
                        Text("09123456789")
                    }
                    
                    Divider()
                    
                    HStack{
                        Text("Location")
                        
                        Spacer()
                        
                        Text("Lucena City")
                    }
                    
                    Divider()
                    
                    HStack{
                        Text("Educational Attainment")
                        
                        Spacer()
                        
                        Text("BS Computer Science")
                    }
                    
                    Divider()
                    
                    HStack{
                        Text("Work Experience")
                        
                        Spacer()
                        
                        Text("2 years")
                    }
                    
                    Divider()
                    
                    HStack(alignment: .top){
                        Text("Core Languages")
                        
                        Spacer()
                        
                        VStack(alignment: .trailing){
                            Text("Python")
                            Text("JavaScript")
                            Text("C++")
                        }
                    }
                    
                    Button{
                        editAccountScreen = true
                    } label: {
                        HStack{
                            Spacer()
                            
                            Image(systemName: "pencil.line")
                                .font(.system(size: 20))
                                .padding(5)
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.white)
                                .background(
                                    Color(
                                        red: 0/255,
                                        green: 61/255,
                                        blue: 92/255
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .frame(minWidth: 365, minHeight: 400)
                .foregroundStyle(.black)
                .background(.white)
                .cornerRadius(10)
                .shadow(
                    radius: 5,
                    x: 0,
                    y: 5
                )
                
                Button{
                    logInScreen = true
                } label: {
                    Text("Sign Out")
                        .fontWeight(.regular)
                        .padding(.horizontal, 20)
                        .frame(width: 280, height: 38)
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.top, 30)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                }
            }
            .frame(width: 350, height:.infinity)
            .appBg()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $logInScreen) {
                LogInPage()
            }
            /*.navigationDestination(isPresented: $editAccountScreen) {
                EditAccountView()
            }*/
        }
    }
}

#Preview {
    AplAccountPage()
}
