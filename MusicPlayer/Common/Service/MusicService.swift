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
    
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private var delegates: [MusicPlayerProtocol] = []
    
    // MARK: - View lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(playSequence), name: .playAlbumSequence, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playSong), name: .playSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shuffleSong), name: .shuffleAlbum, object: nil)
    }
    
    @objc private func playSong(_ notification: Notification) {
        print("notification.userInfo = \(String(describing: notification.userInfo))")
        guard let userInfoAlbum: UserInfoAlbumSpec = notification.userInfo?[UserInfoKey.album] as? UserInfoAlbumSpec else {
            return
        }
        setUserInfoAlbum(userInfoAlbum)
        play()
    }
    
    @objc private func playSequence(_ notification: Notification) {
        guard let userInfoAlbum: UserInfoAlbumSpec = notification.userInfo?[UserInfoKey.album] as? UserInfoAlbumSpec else {
            return
        }
        setUserInfoAlbum(userInfoAlbum)
        play()
    }
    
    @objc private func shuffleSong(_ notification: Notification) {
        guard let userInfoAlbum: UserInfoAlbumSpec = notification.userInfo?[UserInfoKey.album] as? UserInfoAlbumSpec else {
            return
        }
        stop()
        self.musicPlayer.skipToNextItem()
        setUserInfoAlbum(userInfoAlbum)
        
        play()
        if let item = self.musicPlayer.nowPlayingItem {
            self.setMusicControl(item)
        }
    }
    
    private func setUserInfoAlbum(_ spec: UserInfoAlbumSpec) {
        let items: [MPMediaItem] = spec.album.songs.map { return SongQuery.getItem(songId: $0.songId) }
        let collection = MPMediaItemCollection(items: items)
        self.musicPlayer.setQueue(with: collection)
        
        if let index: Int = spec.playIndex {
            let item = collection.items[index]
            self.musicPlayer.nowPlayingItem = item
            self.setMusicControl(item)
        }
        self.musicPlayer.shuffleMode = spec.shuffleMode
    }
    
    private func play() {
        self.delegates.forEach({ $0.play() })
    }
    
    private func stop() {
        self.delegates.forEach({ $0.stop() })
    }
    
    private func setMusicControl(_ item: MPMediaItem) {
        self.delegates.forEach({ $0.setMusicControl(item) })
    }
    
    // MARK: - Public Function
    
    func setDelegate(_ delegate: MusicPlayerProtocol) {
        let contains: Bool = self.delegates.contains(where: { $0 === delegate })
        guard !contains else {
            return
        }
        self.delegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: MusicPlayerProtocol) {
        if let index = self.delegates.firstIndex(where: { $0 === delegate }) {
            self.delegates.remove(at: index)
        }
    }
    
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
