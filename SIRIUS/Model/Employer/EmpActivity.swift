//
//  EmpActivity.swift
//  SIRIUS
//
//  Created by Mac-LAB on 10/2/26.
//

import Foundation

struct EmpActivity: Identifiable {
    let id = UUID()
    var icon: String
    var title: String
    var jobPosition: String
    var timeAgo: String
}
