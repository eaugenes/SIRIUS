//
//  RoleSelectionView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import SwiftUI

struct RoleSelectionPage: View {
    
    @State private var selectedRole: UserRole?
    @State private var nextScreen = false
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center){
                Image("sirius-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .padding(.top, 50)
                
                Text("SIRIUS")
                    .font(.system(size: 64))
                    .fontWeight(.medium)
                    .tracking(15.0)
                    .padding(.leading, 20)
                
                Text("In a sky full of opportunities, let the right one find you.")
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .padding(.bottom, 40)
                
                VStack(alignment: .leading){
                    Text("Choose Your Role")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.black)
                    
                    VStack(spacing: 16){
                        RoleCard(
                            title:"APPLICANT",
                            description: "Find opportunities that match your qualifications.",
                            icon: "person",
                            isSelected: selectedRole == .applicant) {selectedRole = .applicant}
                        
                        RoleCard(
                            title:"EMPLOYER",
                            description: "Find qualified candidates faster.",
                            icon: "person",
                            isSelected: selectedRole == .employer) {selectedRole = .employer}
                        
                        Button {
                            nextScreen = true
                        } label: {
                            Text("Continue")
                                .fontWeight(.regular)
                                .padding(.horizontal, 20)
                                .frame(width: 325, height: 50)
                                .foregroundStyle(Color.black)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        }
                        .disabled(selectedRole == nil)
                    }
                }
                .padding(.horizontal, 20)
                .frame(width: 365,height: 320)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.bottom, 90)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBg()
            .navigationDestination(isPresented: $nextScreen) {
                if selectedRole == .applicant {
                    AplSignUpPage()
                }  else if selectedRole == .employer {
                    EmpSignUpPage()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RoleSelectionPage()
}
