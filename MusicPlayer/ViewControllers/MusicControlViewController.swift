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
    
    let musicPlayer = MusicService.shared.musicPlayer
    var currentSong: Song?
    
    private var timer: Timer?
    private var isTouchingSlider: Bool = false
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
//        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        
//        if currentSong != nil {
//            setMusicControl(currentSong!)
//        }
        
        if let item: MPMediaItem = self.musicPlayer.nowPlayingItem {
            self.setMusicControl(item)
        }
//        NotificationCenter.default.addObserver(self, selector: #selector(changePlayItem), name: Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    private func setupUI() {
        self.topView.layer.cornerRadius = topView.bounds.height / 2.0
        self.coverImageView.layer.cornerRadius = coverImageCornerRadius
        self.songSlider.value = 0.0
        self.songSlider.setThumbImage(#imageLiteral(resourceName: "thumb_small"), for: .normal)
    }
    
    internal func setMusicControl(_ item: MPMediaItem) {
        self.songTitleLabel.text = item.title
        self.artistLabel.text = item.artist
        if let coverImage = item.artwork?.image(at: self.coverImageView.bounds.size) {
            self.coverImageView.image = coverImage
        }
        else {
            self.coverImageView.image = UIImage(named: "placeholder_artwork")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MusicService.shared.setDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MusicService.shared.removeDelegate(self)
    }
    
    // MARK: - IBAction Function
    
    @IBAction func onBackward(_ sender: UIButton) {
        
    }
    
    @IBAction func onPlay(_ sender: UIButton) {
        self.playButton.isSelected = !self.playButton.isSelected
        self.setPlayButton(self.playButton.isSelected)
    }
    
    @IBAction func onForward(_ sender: UIButton) {
        
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
    
    private func setPlayButton(_ isPlaying: Bool) {
        if isPlaying {
            self.playButton.setImage(SymbolName.pause_fill.getImage(.big), for: .normal)
        }
        else {
            self.playButton.setImage(SymbolName.play_fill.getImage(.big), for: .normal)
        }
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
            
            let m = duration.intValue / 60
            let s = duration.intValue % 60
            print("m = \(m), s = \(s)")
            let minute_ = abs(Int((musicPlayer.currentPlaybackTime / 60.0).truncatingRemainder(dividingBy: 60.0)))
            let second_ = abs(Int(musicPlayer.currentPlaybackTime.truncatingRemainder(dividingBy: 60.0)))

            let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
            let second = second_ > 9 ? "\(second_)" : "0\(second_)"
            
            print("음악 재생 : \(musicPlayer.currentPlaybackTime)")
            print("duration = \(duration)")
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

