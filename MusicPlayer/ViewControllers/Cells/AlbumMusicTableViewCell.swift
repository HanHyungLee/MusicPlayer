//
//  AlbumMusicTableViewCell.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

final class AlbumMusicTableViewCell: UITableViewCell {
    @IBOutlet weak var playIconImageView: UIImageView!
    @IBOutlet weak var musicLabel: UILabel!
    
    // MARK: - View lifecycle
    
    func initCell(_ title: String) {
        self.musicLabel.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
