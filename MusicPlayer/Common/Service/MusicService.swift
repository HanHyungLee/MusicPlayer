//
//  MusicService.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/16.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import Foundation
import MediaPlayer

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

extension MusicService {
    enum PlayMode {
        case play
        case playSequence
        case shuffle
    }
}

final class MusicService {
    static let shared = MusicService()
    
    private var userInfoAlbum: UserInfoAlbumSpec?
    
    // MARK: - View lifecycle
    
    deinit {
        
    }
    
    init() {
        
    }
    
    // MARK: - Public Function
    
    func setAlbum(_ album: UserInfoAlbum, playMode: PlayMode) {
        self.userInfoAlbum = album
        
        switch playMode {
        case .play:
            NotificationCenter.default.post(name: .playSong, object: nil, userInfo: [UserInfoKey.album: album])
        case .playSequence:
            NotificationCenter.default.post(name: .playAlbumSequence, object: nil, userInfo: [UserInfoKey.album: album])
        case .shuffle:
            NotificationCenter.default.post(name: .shuffleAlbum, object: nil, userInfo: [UserInfoKey.album: album])
        }
    }
}
