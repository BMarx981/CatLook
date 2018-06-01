//
//  Cat.swift
//  CatLook
//
//  Created by Marx, Brian on 5/31/18.
//  Copyright © 2018 Marx, Brian. All rights reserved.
//

import UIKit

class Cat {
    var name = ""
    var imageURL = String()
    var image = UIImage()
    var description = String()
    var date = String() {
        didSet {
            let components = date.components(separatedBy: "-")
            let day = components[2].components(separatedBy: "T")
            date = "\(components[1])/\(day[0])/\(components[0])"
        }
    }
}
