//
//  Image.swift
//  MasterDetail
//
//  Created by mac022 on 2024/06/11.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
