//
//  Asset.swift
//  Signal 2.0 Demo
//
//  Created by Taha Obed on 05.11.23.
//

import SwiftUI
import Photos

struct Asset: Identifiable {
    var id = UUID().uuidString
    var asset: PHAsset
    var image: UIImage
}
