//
//  Constants.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/13.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import Foundation
import UIKit

let coverImageCornerRadius: CGFloat = 4.0
let buttonCornerRadius: CGFloat = 8.0

struct UserInfoKey {
    static let album: String = "album"
}

enum SymbolName: String {
    case play_fill = "play.fill"
    case pause_fill = "pause.fill"
    case backward_fill = "backward.fill"
    case forward_fill = "forward.fill"
    case repeat_ = "repeat" // 예약어 때문에 마지막에 _ 붙인다.
    case shuffle = "shuffle"
    
    enum Size: CGFloat {
        case small = 15.0
        case big = 30.0
    }
    
    func getImage(_ size: Size) -> UIImage? {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: size.rawValue, weight: .black)
        let playImage = UIImage(systemName: self.rawValue, withConfiguration: symbolConfiguration)
        return playImage
    }
}
