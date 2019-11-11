//
//  Album.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import Foundation
import UIKit

protocol SongProtocol {
    var songId: NSNumber { get set }
    var albumTitle: String { get set }
    var title: String { get set }
    var artistName: String { get set }
    var songTitle: String { get set }
}

struct Song: SongProtocol {
    var songId: NSNumber
    var albumTitle: String
    var title: String
    var artistName: String
    var songTitle: String
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        return lhs.songId == rhs.songId &&
            lhs.albumTitle == rhs.albumTitle
    }
}

struct Album {
    var albumTitle: String
    var artistName: String
    var songs: [SongProtocol]
    var artwork: UIImage? = nil
}

