//
//  MusicDetailViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

protocol CurrentSongDelegate: NSObjectProtocol {
    func didChangePlayState()
    func setCurrentSong(_ song: Song?)
}

extension MusicDetailViewController {
    enum Section {
        case albumInfo(_ albumTitle: String, artist: String, artwork: UIImage?)
        case control
        case musicList(_ songs: [SongProtocol])
    }
}

final class MusicDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var sections: [Section] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    var album: Album? {
        didSet {
            guard let album = album else {
                return
            }
            let albumTitle: String = album.albumTitle
            let artist: String = album.artistName
            let artwork = album.artwork
            
            let albumInfo =
                Section.albumInfo(albumTitle,
                                  artist: artist,
                                  artwork: artwork)
            
            let songs: [SongProtocol] = album.songs
            let musicList = Section.musicList(songs)
            
            self.sections = [albumInfo, .control, musicList]
        }
    }
    
    private var currentSong: Song? = MusicService.shared.currentSong {
        didSet {
            self.reloadMusicListSection()
        }
    }
    
    private var prevPlayState = MusicService.shared.musicPlayer.playbackState
    
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
        MusicService.shared.songDelegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MusicService.shared.songDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableViewDataSource
extension MusicDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.sections[section]
        switch section {
        case .musicList(let songs):
            return songs.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        switch section {
        case .albumInfo(let albumTitle, let artist, let artwork):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumInfoTableViewCell", for: indexPath) as! AlbumInfoTableViewCell
            cell.initCell(albumTitle, artist: artist, artwork: artwork)
            return cell
        case .control:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumControlTableViewCell", for: indexPath) as! AlbumControlTableViewCell
            cell.delegate = self
            return cell
        case .musicList(let songs):
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumMusicTableViewCell", for: indexPath) as! AlbumMusicTableViewCell
            if let song: Song = songs[indexPath.row] as? Song {
                cell.initCell(song.songTitle)
                if let currentSong: Song = self.currentSong,
                    currentSong == song {
                    if MusicService.shared.isMusicPlaying {
                        cell.state = .playing
                    }
                    else {
                        cell.state = .paused
                    }
                }
                else {
                    cell.state = .stopped
                }
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension MusicDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = self.sections[indexPath.section]
        switch section {
        case .albumInfo(_, _, _):
            return 180.0
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        switch section {
        case .musicList(_):
            if let album = self.album {
                let userInfoAlbum = UserInfoAlbum(album: album, shuffleMode: .off, playIndex: indexPath.row)
                MusicService.shared.setAlbum(userInfoAlbum, playMode: .shuffle)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MusicDetailViewController: AlbumControlTableViewCellDelegate {
    func tapPlay() {
        if let album = self.album {
            let userInfoAlbum = UserInfoAlbum(album: album, shuffleMode: .off, playIndex: 0)
            MusicService.shared.setAlbum(userInfoAlbum, playMode: .play)
        }
    }
    
    func tapShuffle() {
        if let album = self.album {
            let userInfoAlbum = UserInfoAlbum(album: album, shuffleMode: .albums, playIndex: nil)
            MusicService.shared.setAlbum(userInfoAlbum, playMode: .shuffle)
        }
    }
}

extension MusicDetailViewController: CurrentSongDelegate {
    func setCurrentSong(_ song: Song?) {
        self.currentSong = song
    }
    
    func didChangePlayState() {
        let currentPlayState = MusicService.shared.musicPlayer.playbackState
        if self.prevPlayState != currentPlayState {
            self.prevPlayState = currentPlayState
            self.reloadMusicListSection()
        }
    }
    
    private func reloadMusicListSection() {
        if let section = self.sections.firstIndex(where: { section -> Bool in
            switch section {
            case .musicList(_):
                return true
            default:
                return false
            }
        }) {
            let indexSet = IndexSet(integer: section)
            self.tableView.reloadSections(indexSet, with: .none)
        }
    }
}
