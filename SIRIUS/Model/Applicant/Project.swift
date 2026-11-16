//
//  Project.swift
//  SIRIUS
//
//  Created by Mac-LAB on 11/12/26.
//

import Foundation
import UIKit

struct Project: Identifiable {
    static let titleLimit = 30
    static let descriptionLimit = 100
    static let maxPictures = 3
    static let maxProjects = 5

    var id = UUID()
    var title = ""
    var details = ""
    var imagePaths: [String] = []
    var newImages: [UIImage] = []

    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    var trimmedDetails: String { details.trimmingCharacters(in: .whitespacesAndNewlines) }
    var pictureCount: Int { imagePaths.count + newImages.count }

    var isBlank: Bool { trimmedTitle.isEmpty && trimmedDetails.isEmpty && pictureCount == 0 }

    var isComplete: Bool { !trimmedTitle.isEmpty && !trimmedDetails.isEmpty }
}
