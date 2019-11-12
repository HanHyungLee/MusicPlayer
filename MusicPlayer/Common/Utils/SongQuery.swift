//
//  SongQuery.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import Foundation
import MediaPlayer

enum SongCategory {
    case artist
    case album
}

class SongQuery {
    /// 모든 음악 쿼리
    func get(category: SongCategory) -> [Album] {
        var albums = [Album]()
        let albumsQuery: MPMediaQuery
        
        switch category {
        case .artist:
            albumsQuery = MPMediaQuery.artists()
        case .album:
            albumsQuery = MPMediaQuery.albums()
        }
        
        let albumItems: [MPMediaItemCollection] = albumsQuery.collections ?? []
        
        for album in albumItems {
            let albumItems: [MPMediaItem] = album.items
            
            var songs: [SongProtocol] = []

            var albumTitle: String = ""
            let artist: String = album.representativeItem?.artist ?? ""
            let artwork: UIImage? = album.representativeItem?.artwork?.image(at: CGSize(width: 300, height: 300))
            
            for song in albumItems {
                switch category {
                case .artist:
                    albumTitle = song.value(forProperty: MPMediaItemPropertyArtist) as! String
                case .album:
                    albumTitle = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
                }
                
                guard let songId: NSNumber = song.value(forProperty: MPMediaItemPropertyPersistentID) as? NSNumber,
                    let albumTitle: String = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as? String,
                    let artistName: String = song.value(forProperty: MPMediaItemPropertyArtist) as? String,
                    let songTitle: String =  song.value(forProperty: MPMediaItemPropertyTitle) as? String
                    else {
                    continue
                }
                
                let song: Song = Song(songId: songId,
                                      albumTitle: albumTitle,
                                      title: songTitle,
                                      artistName: artistName,
                                      songTitle: songTitle)
                
                songs.append(song)
            }
            
            let album = Album(albumTitle: albumTitle,
                              artistName: artist,
                              songs: songs,
                              artwork: artwork)
            
            albums.append(album)
        }
        
        return albums
    }
    
    /// MPMediaItem 찾기
    static func getItem(songId: NSNumber) -> MPMediaItem {
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: songId, forProperty: MPMediaItemPropertyPersistentID)
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate(property)
        
        let items: [MPMediaItem] = query.items! as [MPMediaItem]
        
        return items[items.count - 1]
    }
}
