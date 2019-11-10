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
            
            for song in albumItems {
                switch category {
                case .artist:
                    albumTitle = song.value( forProperty: MPMediaItemPropertyArtist ) as! String
                case .album:
                    albumTitle = song.value( forProperty: MPMediaItemPropertyAlbumTitle ) as! String
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
            
            let album = Album(albumTitle: albumTitle, songs: songs)
            
            albums.append(album)
        }
        
        return albums
    }
}
