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
    
    static let viewController: MusicControlViewController = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MusicControlViewController") as! MusicControlViewController
    }()
    var currentSong: Song?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func play() {
        
    }
    
    func pause() {
        
    }
    
    func backward() {
        
    }
    
    func forward() {
        
    }
    
}

