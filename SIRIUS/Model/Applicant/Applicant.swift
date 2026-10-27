//
//  Applicant.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import Foundation
import UIKit                // for UIImage

struct Applicant: Codable {
    var id = UUID()
    var firstName: String
    var middleName: String
    var lastName: String
    var contactNumber: String
    var location: String
    var program: String
    var yrExp: Double
    var coreLang: [String]
    var workSetUp: String

    var email: String
    var password: String
    
    var profilePicture: UIImage? = nil     // temporarily store  selected photo and ensure that the pfp is not optional, if no picture yet, display Image(systemName: "person")
    var birthDate: String = ""
    var username: String = ""
    var resumeFileName: String = ""        // TODO(Supabase Storage): upload resumeData and store its path instead
    var resumeData: Data? = nil
    
    // The profile photo (UIImage) is not stored in the JSON file
    private enum CodingKeys: String, CodingKey {
        case id, firstName, middleName, lastName, contactNumber, location, program
        case yrExp, coreLang, workSetUp, email, password, birthDate, username, resumeFileName
    }
    
    var fullName: String {
        [firstName, middleName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var matchProfile: MatchProfile {
        MatchProfile(program: program, yearsExperience: yrExp, languages: coreLang, location: location)
    }
}
