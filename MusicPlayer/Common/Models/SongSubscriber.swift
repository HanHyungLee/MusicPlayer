//
//  SongSubscriber.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/12.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import Foundation
import MediaPlayer

protocol SongSubscriber: class {
  var currentSong: Song? { get set }
}

// Notification userInfo에 전달할 앨범 스펙
protocol UserInfoAlbumSpec {
    var album: Album { get set }
    var shuffleMode: MPMusicShuffleMode { get }
    var playIndex: Int? { get }
}

struct UserInfoAlbum: UserInfoAlbumSpec {
    var album: Album
    var shuffleMode: MPMusicShuffleMode
    var playIndex: Int?
}
