//
//  ImageService.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/23.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import Foundation
import UIKit

class ImageService {

    static let cache = NSCache<NSString, UIImage>()

    static func downloadImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseUrl, error in
            var downloadedImage: UIImage?

            if let data = data {
                downloadedImage = UIImage(data: data)
            }

            if let downloadedImage = downloadedImage {
                cache.setObject(downloadedImage, forKey: url.absoluteString as NSString)
            }

            DispatchQueue.main.async {
                completion(downloadedImage)
            }

        }
        dataTask.resume()
    }

    static func getImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            completion(image)
        } else {
            downloadImage(withURL: url, completion: completion)
        }
    }
}
