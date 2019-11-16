//
//  MusicMiniControlViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/13.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit
import MediaPlayer

protocol MusicPlayerProtocol {
    func play()
    func stop()
    func backward()
    func forward()
}

protocol MusicMiniControlViewControllerDelegate: NSObjectProtocol {
    func expandSong(_ song: Song?)
}

final class MusicMiniControlViewController: UIViewController, SongSubscriber, MusicPlayerProtocol {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    private var timer: Timer?
    
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    var currentSong: Song?
    var delegate: MusicMiniControlViewControllerDelegate?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(shuffleSong), name: .shuffleAlbum, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayItem), name: Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
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
    
    @objc private func changePlayItem(_ notification: Notification) {
        print("changePlayItem notification = \(notification)")
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - IBAction Function
    
    @IBAction func tapGesture(_ sender: Any) {
//        guard let song = currentSong else {
//            return
//        }
        self.delegate?.expandSong(currentSong)
    }
    
    @IBAction func onPlayButton(_ sender: UIButton) {
        let isPlaying: Bool = self.musicPlayer.playbackState == .playing
        self.setPlayButton(isPlaying)
        // play or stop
        isPlaying ? stop() : play()
    }
    
    private func setPlayButton(_ isPlaying: Bool) {
        if isPlaying {
            self.playButton.setImage(#imageLiteral(resourceName: "MPPause"), for: .normal)
        }
        else {
            self.playButton.setImage(#imageLiteral(resourceName: "MPPlay"), for: .normal)
        }
    }
    
    @IBAction func changeSongTime(_ sender: UISlider) {
        let value = sender.value
        print("value = \(value)")
        self.musicPlayer.currentPlaybackTime = TimeInterval(value)
    }
    
    // MARK: - MusicPlayerProtocol
    
    func play() {
        self.musicPlayer.play()
        self.setPlayButton(true)
        startTimer()
    }
    
    func stop() {
        self.musicPlayer.shuffleMode = .off

        self.musicPlayer.stop()
        self.setPlayButton(false)
        stopTimer()
    }
    
    func backward() {
        self.musicPlayer.beginSeekingBackward()
    }
    
    func forward() {
        self.musicPlayer.beginSeekingForward()
    }
    
    private func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update(timer:)), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    @objc private func update(timer: Timer) {
        switch self.musicPlayer.playbackState {
        case .playing:
            let duration = self.musicPlayer.nowPlayingItem?.value(forProperty: MPMediaItemPropertyPlaybackDuration) as! NSNumber
//            let m = duration.intValue / 60
//            let s = duration.intValue % 60
//            print("m = \(m), s = \(s)")
//            let minute_ = abs(Int((musicPlayer.currentPlaybackTime / 60.0).truncatingRemainder(dividingBy: 60.0)))
//            let second_ = abs(Int(musicPlayer.currentPlaybackTime.truncatingRemainder(dividingBy: 60.0)))
//            
//            let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
//            let second = second_ > 9 ? "\(second_)" : "0\(second_)"
            
            print("음악 재생 : \(musicPlayer.currentPlaybackTime)")
            print("duration = \(duration)")
            self.slider.maximumValue = duration.floatValue
            self.slider.value = Float(musicPlayer.currentPlaybackTime)
        default:
            return
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
    }
}
