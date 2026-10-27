//
//  ProfileImagePicker.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/11/26.
//

import SwiftUI
import UIKit
import PhotosUI         // for PhotosPickerItem to show the photo the user selected from album

struct ProfileImagePicker: View {
    
    @Binding var image: UIImage?
    @State private var showImageOptions: Bool = false
    @State private var showPhotoAlbum: Bool = false
    @State private var showCamera: Bool = false
    @State private var selectedOption: PhotosPickerItem?
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Group{      //      Group{} - Invisible container for switching images
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 131, height: 131)
                } else {
                    Image(systemName: "person")
                        .scaledFont(size: 35)
                        .foregroundColor(.white)
                        .frame(width: 131, height: 131)
                }
            }
            .frame(width: 131, height: 131)
            .background(Color.siriusPanel)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
            
            Button {
                showImageOptions = true
            } label: {
                Image(systemName: "camera.fill")
                    .scaledFont(size: 12)
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Color.siriusNavy)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            .padding(.trailing, 10)
            .padding(.bottom, 10)
            .accessibilityLabel("Change profile picture")
        }
        .frame(width: 131, height: 131)
        .photosPicker(
            isPresented: $showImageOptions,
            selection: $selectedOption,
            matching: .images
        )
        
        .sheet(isPresented: $showCamera) {
            CameraView(image: $image)
        }
        
        .onChange(of: selectedOption) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                                image = uiImage
                        }
                    }
                }
    }
}
