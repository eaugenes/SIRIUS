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
    var details = ""                    // the "description" column in the database
    var imagePaths: [String] = []       // pictures already uploaded (Supabase Storage paths)
    var newImages: [UIImage] = []       // pictures picked but not uploaded yet
    
    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    var trimmedDetails: String { details.trimmingCharacters(in: .whitespacesAndNewlines) }
    var pictureCount: Int { imagePaths.count + newImages.count }
    
    // Nothing typed and no picture: such a project is removed automatically
    var isBlank: Bool { trimmedTitle.isEmpty && trimmedDetails.isEmpty && pictureCount == 0 }
    
    // Both required fields are filled in
    var isComplete: Bool { !trimmedTitle.isEmpty && !trimmedDetails.isEmpty }
}
