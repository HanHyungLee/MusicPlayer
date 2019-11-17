//
//  MusicListViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit
import MediaPlayer

extension MusicListViewController {
    enum MediaError: Error {
        case error(MPMediaLibraryAuthorizationStatus)
        case unknownError
    }
}

final class MusicListViewController: UIViewController {
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    private var albums: [Album] = [] {
        didSet {
            self.listCollectionView.reloadData()
        }
    }
    private var songQuery = SongQuery()
    
    private let cellPadding: CGFloat = 20.0
    
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "라이브러리"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.definesPresentationContext = true
        
        getMusicAlbum()
    }
    
    private func getMusicAlbum() {
        do {
            try self.getMusicAuthorization()
        }
        catch MediaError.error(_) {
            self.alert("음악 접근 권한을 허용해야 합니다.", ok: "확인") {
                // TODO: 설정으로 보낼까?
            }
        }
        catch MediaError.unknownError {
            self.alert("음악에 접근할 수 없습니다.", ok: "확인", completion: nil)
        }
        catch {
            self.alert(error.localizedDescription, ok: "확인", completion: nil)
        }
    }
    
    private func getMusicAuthorization() throws {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            let albums = self.songQuery.get(category: .album)
//            print("albums = \(albums)")
            self.albums = albums
        case .denied, .restricted:
            throw MediaError.error(status)
        case .notDetermined:
            let semaphore = DispatchSemaphore(value: 0)
            
            MPMediaLibrary.requestAuthorization { status in
                semaphore.signal()
            }
            
            semaphore.wait()
            
            let newStatus = MPMediaLibrary.authorizationStatus()
            
            switch newStatus {
            case .authorized:
                let albums = self.songQuery.get(category: .album)
//                print("albums = \(albums)")
                self.albums = albums
            case .denied, .restricted, .notDetermined:
                throw MediaError.error(status)
            @unknown default:
                throw MediaError.unknownError
            }
        @unknown default:
            throw MediaError.unknownError
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let musicDetailVC = segue.destination as? MusicDetailViewController,
            let album: Album = sender as? Album {
            musicDetailVC.album = album
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MusicListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath) as! AlbumCollectionViewCell
        let album: Album = self.albums[indexPath.row]
        cell.initCell(album)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MusicListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album: Album = self.albums[indexPath.row]
        self.performSegue(withIdentifier: "showAlbum", sender: album)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MusicListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.size.width - cellPadding * 3.0) / 2.0
        let height: CGFloat = width + AlbumCollectionViewCell.labelSize
        return CGSize(width: width, height: height)
    }
}
