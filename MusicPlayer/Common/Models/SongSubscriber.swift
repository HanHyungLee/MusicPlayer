//
//  SongSubscriber.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/12.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import Foundation

protocol SongSubscriber: class {
  var currentSong: Song? { get set }
}
