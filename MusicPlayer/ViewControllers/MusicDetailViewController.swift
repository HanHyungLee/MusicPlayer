//
//  MusicDetailViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

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
    
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
}

extension MusicDetailViewController: AlbumControlTableViewCellDelegate {
    func tapPlay() {
        print("재생")
    }
    
    func tapShuffle() {
        print("랜덤 재생")
    }
}
