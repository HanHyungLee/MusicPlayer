//
//  MusicMiniControlViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/13.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit
import MediaPlayer

protocol MusicPlayerProtocol: class {
    func play()
    func stop()
    func backward()
    func forward()
    func setMusicControl(_ item: MPMediaItem?)
}

protocol MusicMiniControlViewControllerDelegate: NSObjectProtocol {
    func expandSong(_ song: Song?)
}

final class MusicMiniControlViewController: UIViewController, SongSubscriber, MusicPlayerProtocol {
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    private var timer: Timer?
    private var isTouchingSlider: Bool = false
    
//    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    var currentSong: Song?
    weak var delegate: MusicMiniControlViewControllerDelegate?
    let musicPlayer = MusicService.shared.musicPlayer
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let item = self.musicPlayer.nowPlayingItem
        self.setMusicControl(item)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changePlayItem), name: Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    private func setupUI() {
        self.coverImageView.layer.cornerRadius = coverImageCornerRadius
        self.songSlider.value = 0.0
        self.songSlider.setThumbImage(#imageLiteral(resourceName: "thumb_small"), for: .normal)
    }
    
    internal func setMusicControl(_ item: MPMediaItem?) {
        self.titleLabel.text = item?.title ?? "Not Playing"
        self.artistLabel.text = item?.artist
        if let coverImage = item?.artwork?.image(at: self.coverImageView.bounds.size) {
            self.coverImageView.image = coverImage
        }
        else {
            self.coverImageView.image = UIImage(named: "placeholder_artwork")
        }
    }
    
    @objc private func changePlayItem(_ notification: Notification) {
        print("changePlayItem notification = \(notification)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MusicService.shared.setDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MusicService.shared.removeDelegate(self)
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
            self.playButton.setImage(SymbolName.pause_fill.getImage(.big), for: .normal)
        }
        else {
            self.playButton.setImage(SymbolName.play_fill.getImage(.big), for: .normal)
        }
    }
    
    @IBAction func touchSlider(_ sender: UISlider) {
        self.isTouchingSlider = true
        sender.setThumbImage(nil, for: .normal)
    }
    
    @IBAction func touchUpSlider(_ sender: UISlider) {
        self.isTouchingSlider = false
        sender.setThumbImage(#imageLiteral(resourceName: "thumb_small"), for: .normal)
    }
    
    @IBAction func changeSongTime(_ sender: UISlider) {
        let value = sender.value
        print("value = \(value)")
        guard self.musicPlayer.nowPlayingItem != nil else {
            return
        }
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
            print("음악 재생 : \(musicPlayer.currentPlaybackTime)")
            print("duration = \(duration)")
            
            guard self.isTouchingSlider == false else {
                return
            }
            self.songSlider.maximumValue = duration.floatValue
            self.songSlider.value = Float(musicPlayer.currentPlaybackTime)
        default:
            return
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
    }
}
