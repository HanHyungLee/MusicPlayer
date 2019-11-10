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
    
    @IBOutlet weak var listTableView: UITableView!
    
    var albums: [Album] = [] {
        didSet {
            self.listTableView.reloadData()
        }
    }
    var songQuery = SongQuery()
    
    
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
            print("albums = \(albums)")
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
                print("albums = \(albums)")
            case .denied, .restricted, .notDetermined:
                throw MediaError.error(status)
            @unknown default:
                throw MediaError.unknownError
            }
        @unknown default:
            throw MediaError.unknownError
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

}

// MARK: - UITableViewDataSource
extension MusicListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

// MARK: - UITableViewDelegate
extension MusicListViewController: UITableViewDelegate {
    
}
