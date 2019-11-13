//
//  MusicControlViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/11.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit
import MediaPlayer

protocol MusicPlayerProtocol {
    func play()
    func pause()
    func backward()
    func forward()
}

extension Notification.Name {
    static let playSong = Notification.Name("playSong")
    static let playAlbumSequence = Notification.Name("playAlbumSequence")
    static let shuffleAlbum = Notification.Name("shuffleAlbum")
}

final class MusicControlViewController: UIViewController, SongSubscriber, MusicPlayerProtocol {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    var currentSong: Song?
    
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coverImageView.layer.cornerRadius = coverImageCornerRadius
        
        if let item: MPMediaItem = self.musicPlayer.nowPlayingItem {
            self.setMusicControl(item)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playSequence), name: .playAlbumSequence, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playSong), name: .playSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shffleSong), name: .shuffleAlbum, object: nil)
    }
    
    private func setMusicControl(_ item: MPMediaItem) {
        self.titleLabel.text = item.title
        self.artistLabel.text = item.artist
        if let coverImage = item.artwork?.image(at: self.coverImageView.bounds.size) {
            self.coverImageView.image = coverImage
        }
        else {
            self.coverImageView.image = UIImage(named: "placeholder_artwork")
        }
        self.setPlayButton(self.musicPlayer.playbackState == .playing)
    }
    
    @objc private func playSong(_ notification: Notification) {
        print("notification.userInfo = \(String(describing: notification.userInfo))")
        
        if let song: SongProtocol = notification.userInfo?["song"] as? SongProtocol {
            let item: MPMediaItem = SongQuery.getItem(songId: song.songId)
            let collection = MPMediaItemCollection(items: [item])
            self.musicPlayer.setQueue(with: collection)
            self.musicPlayer.play()
            self.setMusicControl(item)
        }
    }
    
    @objc private func playSequence(_ notification: Notification) {
        if let songs: [SongProtocol] = notification.userInfo?["songs"] as? [SongProtocol] {
            let items: [MPMediaItem] = songs.map { return SongQuery.getItem(songId: $0.songId) }
            let collection = MPMediaItemCollection(items: items)
            self.musicPlayer.setQueue(with: collection)
            self.musicPlayer.shuffleMode = .off
            self.musicPlayer.skipToBeginning()
            let item = collection.items[self.musicPlayer.indexOfNowPlayingItem]
            self.setMusicControl(item)
            self.play()
        }
    }
    
    @objc private func shffleSong(_ notification: Notification) {
        self.musicPlayer.shuffleMode = .albums
        self.musicPlayer.skipToNextItem()
        print("self.musicPlayer.indexOfNowPlayingItem = \(self.musicPlayer.indexOfNowPlayingItem)")
        if let item = self.musicPlayer.nowPlayingItem {
            self.setMusicControl(item)
        }
    }
    
    private func setPlayButton(_ isPlaying: Bool) {
        if isPlaying {
            self.play()
            self.playButton.setImage(#imageLiteral(resourceName: "MPPause"), for: .normal)
        }
        else {
            self.pause()
            self.playButton.setImage(#imageLiteral(resourceName: "MPPlay"), for: .normal)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBAction Function
    
    @IBAction func onPlayButton(_ sender: UIButton) {
        self.setPlayButton(self.musicPlayer.playbackState == .playing)
    }
    
    // MARK: - MusicPlayerProtocol
    
    func play() {
        self.musicPlayer.play()
    }
    
    func pause() {
        self.musicPlayer.pause()
    }
    
    func backward() {
        self.musicPlayer.beginSeekingBackward()
    }
    
    func forward() {
        self.musicPlayer.beginSeekingForward()
    }

//    func setupRemoteTransportControls() {
//        // Get the shared MPRemoteCommandCenter
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//        // Add handler for Play Command
//        commandCenter.playCommand.addTarget { [unowned self] event in
//            if self.player.rate == 0.0 {
//                self.player.play()
//                return .success
//            }
//            return .commandFailed
//        }
//
//        // Add handler for Pause Command
//        commandCenter.pauseCommand.addTarget { [unowned self] event in
//            if self.player.rate == 1.0 {
//                self.player.pause()
//                return .success
//            }
//            return .commandFailed
//        }
//    }
//
//    func setupNowPlaying(_ song: Song) {
//
//        // Define Now Playing Info
//        var nowPlayingInfo = [String: Any]()
//        nowPlayingInfo[MPMediaItemPropertyTitle] = song.songTitle
//
//        if let image = UIImage(named: "lockscreen") {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] =
//                MPMediaItemArtwork(boundsSize: image.size) { size in
//                    return image
//            }
//        }
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds
//        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
//
//        // Set the metadata
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
//
}

