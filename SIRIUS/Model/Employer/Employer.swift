//
//  Employer.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import Foundation
import UIKit

struct Employer: Codable {
    var id = UUID()
    var firstName: String = ""
    var middleName: String = ""
    var lastName: String = ""
    var birthDate: String = ""
    var contactNumber: String = ""
    var email: String = ""
    
    var username: String = ""
    var password: String = ""
    
    var profilePicture: UIImage? = nil
    
    // The profile photo (UIImage) is not stored in the JSON file
    private enum CodingKeys: String, CodingKey {
        case id, firstName, middleName, lastName, birthDate, contactNumber, email, username, password
    }
}
