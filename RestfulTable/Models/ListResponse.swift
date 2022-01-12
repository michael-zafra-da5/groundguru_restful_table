//
//  ListResponse.swift
//  RestfulTable
//
//  Created by Michael Angelo Zafra on 1/12/22.
//

import Foundation

struct ListResponse: Codable {
    var page: Int
    var per_page: Int
    var total: Int
    var total_pages: Int
    var data: [UserData]
}

struct UserData: Codable {
    var id: Int
    var email: String
    var first_name: String
    var last_name: String
    var avatar: String
}
