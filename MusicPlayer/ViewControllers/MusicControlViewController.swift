//
//  MusicControlViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/11.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit
import MediaPlayer

final class MusicControlViewController: UIViewController, SongSubscriber, MusicPlayerDelegate {
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
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    
    let musicPlayer = MusicService.shared.musicPlayer
    var currentSong: Song?
    
    private var timer: Timer?
    private var isTouchingSlider: Bool = false
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
//        if currentSong != nil {
//            setMusicControl(currentSong!)
//        }
        
        if let item: MPMediaItem = self.musicPlayer.nowPlayingItem {
            self.setMusicControl(item)
            self.setTimeLabel(item)
            self.startTimer()
        }
        else {
            self.setMusicControl(nil)
        }
    }
    
    private func setupUI() {
        self.topView.layer.cornerRadius = topView.bounds.height / 2.0
        self.coverImageView.layer.cornerRadius = coverImageCornerRadius
        self.songSlider.value = 0.0
        self.songSlider.setThumbImage(#imageLiteral(resourceName: "thumb_small"), for: .normal)
        
        self.volumeView.setVolumeThumbImage(#imageLiteral(resourceName: "thumb_small"), for: .normal)
//        self.volumeView.showsRouteButton = false
    }
    
    internal func setMusicControl(_ item: MPMediaItem?) {
        self.songTitleLabel.text = item?.title ?? "Not Playing"
        self.artistLabel.text = item?.artist
        if let coverImage = item?.artwork?.image(at: self.coverImageView.bounds.size) {
            self.coverImageView.image = coverImage
        }
        else {
            self.coverImageView.image = UIImage(named: "placeholder_artwork")
        }
        let isPlaying: Bool = self.musicPlayer.playbackState == .playing
        self.setPlayButton(isPlaying)
        self.animatePlayCoverImage(isPlaying)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MusicService.shared.setDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MusicService.shared.removeDelegate(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    // MARK: - IBAction Function
    
    @IBAction func onBackward(_ sender: UIButton) {
        MusicService.shared.backward()
    }
    
    @IBAction func onPlay(_ sender: UIButton) {
        let isPlaying: Bool = self.musicPlayer.playbackState == .playing
        // play or stop
        isPlaying ? MusicService.shared.stop() : MusicService.shared.play()
        // isPlaying 반대로 넣는다.
        self.animatePlayCoverImage(!isPlaying)
    }
    
    private func animatePlayCoverImage(_ isPlaying: Bool) {
        if isPlaying {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.coverImageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.coverImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            })
        }
        else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.coverImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: nil)
        }
    }
    
    private func setPlayButton(_ isPlaying: Bool) {
        if isPlaying {
            self.playButton.setImage(SymbolName.pause_fill.getImage(.big), for: .normal)
        }
        else {
            self.playButton.setImage(SymbolName.play_fill.getImage(.big), for: .normal)
        }
    }
    
    @IBAction func onForward(_ sender: UIButton) {
        MusicService.shared.forward()
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
    
    @IBAction func onRepeat(_ sender: UIButton) {
        self.repeatButton.isSelected = !self.repeatButton.isSelected
        
        if self.repeatButton.isSelected {
            self.musicPlayer.repeatMode = .one
        }
        else {
            self.musicPlayer.repeatMode = .all
        }
    }
    
    private func setRepeatButton(_ state: MPMusicRepeatMode) {
        switch state {
        case .one:
            self.repeatButton.isSelected = true
        default:
            self.repeatButton.isSelected = false
        }
    }
    
    @IBAction func onShuffle(_ sender: UIButton) {
        self.shuffleButton.isSelected = !self.shuffleButton.isSelected
        
        if self.shuffleButton.isSelected {
            self.musicPlayer.shuffleMode = .albums
            self.shuffleButton.alpha = 1.0
        }
        else {
            self.musicPlayer.repeatMode = .none
            self.shuffleButton.alpha = 0.5
        }
    }
    
    // MARK: - MusicPlayerDelegate
    
    func didPlay() {
        self.setPlayButton(true)
        startTimer()
    }
    
    func didStop() {
        self.setPlayButton(false)
        stopTimer()
    }
    
    private func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update(timer:)), userInfo: nil, repeats: true)
            timer?.fire()
        }
        else {
            timer?.fire()
        }
    }
    
    @objc private func update(timer: Timer) {
        switch self.musicPlayer.playbackState {
        case .playing:
            guard let item = self.musicPlayer.nowPlayingItem else {
                return
            }
            
            self.setTimeLabel(item)
        default:
            return
        }
    }
    
    private func setTimeLabel(_ item: MPMediaItem) {
        guard let duration = item.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? NSNumber else {
            return
        }
        
        let m = duration.intValue / 60
        let s = duration.intValue % 60
        
        let minute_ = abs(Int((musicPlayer.currentPlaybackTime / 60.0).truncatingRemainder(dividingBy: 60.0)))
        let second_ = abs(Int(musicPlayer.currentPlaybackTime.truncatingRemainder(dividingBy: 60.0)))
        
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        
        let maxMinute = m > 9 ? "\(m)" : "0\(m)"
        let maxSecond = s > 9 ? "\(s)" : "0\(s)"
        
        self.currentTimeLabel.text = "\(minute):\(second)"
        self.maxTimeLabel.text = "\(maxMinute):\(maxSecond)"
        
        self.setTimeSlider(duration)
    }
    
    private func setTimeSlider(_ duration: NSNumber) {
        guard self.isTouchingSlider == false else {
            return
        }
        print("musicPlayer.currentPlaybackTime : \(musicPlayer.currentPlaybackTime)")
        print("duration = \(duration)")
        
        self.songSlider.maximumValue = duration.floatValue
        self.songSlider.value = Float(musicPlayer.currentPlaybackTime)
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func didChangeMusic(_ item: MPMediaItem?) {
        if let item: MPMediaItem = item {
            self.setMusicControl(item)
            self.startTimer()
        }
        else {
            self.setMusicControl(nil)
        }
    }
}
