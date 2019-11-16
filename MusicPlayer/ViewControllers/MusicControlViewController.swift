//
//  MusicControlViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/11.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit
import MediaPlayer

final class MusicControlViewController: UIViewController, SongSubscriber, MusicPlayerProtocol {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var maxTimeLabel: UILabel!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    static let viewController: MusicControlViewController = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MusicControlViewController") as! MusicControlViewController
    }()
    
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var currentSong: Song?
    
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.layer.cornerRadius = topView.bounds.height / 2.0
        
//        if currentSong != nil {
//            setMusicControl(currentSong!)
//        }
        
        self.coverImageView.layer.cornerRadius = coverImageCornerRadius
        
        if let item: MPMediaItem = self.musicPlayer.nowPlayingItem {
            self.setMusicControl(item)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playSequence), name: .playAlbumSequence, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playSong), name: .playSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shuffleSong), name: .shuffleAlbum, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(changePlayItem), name: Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    private func setMusicControl(_ item: MPMediaItem) {
        self.songTitleLabel.text = item.title
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
    
    // MARK: - IBAction Function
    
    @IBAction func onBackward(_ sender: UIButton) {
        
    }
    
    @IBAction func onPlay(_ sender: UIButton) {
        
    }
    
    @IBAction func onForward(_ sender: UIButton) {
        
    }
    
    
    // MARK: - MusicPlayerProtocol
    
    func play() {
        
    }
    
    func stop() {
        
    }
    
    func backward() {
        
    }
    
    func forward() {
        
    }
    
}

