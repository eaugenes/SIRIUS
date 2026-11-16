//
//  Company.swift
//  SIRIUS
//
//  Created by Mac-LAB on 9/8/26.
//

import Foundation

struct Company: Identifiable {
    var id: String = UUID().uuidString
    var cmpName: String = ""
    var cmpDesc: String = ""
    var loc: String = ""

    var founded: String = ""
    var email: String = ""
    var website: String = ""

    var cmpId: String {id}
}
