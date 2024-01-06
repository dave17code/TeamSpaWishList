//
//  RemoteProduct.swift
//  TeamSpaWishList
//
//  Created by woonKim on 2024/01/06.
//

import Foundation

struct RemoteProduct: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let thumbnail: URL
}
