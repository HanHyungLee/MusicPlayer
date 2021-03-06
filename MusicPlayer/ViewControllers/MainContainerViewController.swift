//
//  MainContainerViewController.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/13.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

final class MainContainerViewController: UIViewController {
    var miniPlayer: MusicMiniControlViewController?
    var musicNavigationController: MusicNavigationViewController?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? MusicMiniControlViewController {
            miniPlayer = destination
            miniPlayer?.delegate = self
        }
        else if let destination = segue.destination as? MusicNavigationViewController {
            musicNavigationController = destination
        }
    }
    
}

// MARK: - MusicMiniControlViewControllerDelegate
extension MainContainerViewController: MusicMiniControlViewControllerDelegate {
    func expandSong() {
        let musicControlViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MusicControlViewController") as! MusicControlViewController
        self.present(musicControlViewController, animated: true, completion: nil)
    }
}
