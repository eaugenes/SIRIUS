//
//  CameraView.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/11/26.
//

import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {

    @Binding var image : UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let camera = UIImagePickerController()

        camera.sourceType = .camera
        camera.delegate = context.coordinator

        return camera
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let capturedImage = info[.originalImage] as? UIImage {
                parent.image = capturedImage
            }

            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
