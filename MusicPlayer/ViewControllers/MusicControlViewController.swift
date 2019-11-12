//
//  MusicControlViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/11.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit
import MediaPlayer

extension Notification.Name {
    static let PlaySong = Notification.Name("playSong")
}

final class MusicControlViewController: UIViewController, SongSubscriber {
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
        
        if let item: MPMediaItem = self.musicPlayer.nowPlayingItem {
            self.setMusicControl(item)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playSong), name: .PlaySong, object: nil)
    }
    
    private func setMusicControl(_ item: MPMediaItem) {
        self.titleLabel.text = item.title
        self.artistLabel.text = item.artist
        self.coverImageView.image = item.artwork?.image(at: self.coverImageView.bounds.size)
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
    
    private func setPlayButton(_ isPlaying: Bool) {
        if isPlaying {
            self.musicPlayer.play()
            self.playButton.setImage(#imageLiteral(resourceName: "MPPause"), for: .normal)
        }
        else {
            self.musicPlayer.pause()
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

