//
//  AlbumInfoTableViewCell.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

final class AlbumInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    
    // MARK: - View lifecycle
    
    deinit {
        print("\(#file), \(#line), \(#function)")
    }
    
    func initCell(_ albumTitle: String, artist: String, artwork: UIImage? = nil) {
        self.albumTitleLabel.text = albumTitle
        self.artistLabel.text = artist
        if let artwork = artwork {
            self.coverImageView.image = artwork
        }
        else {
            self.coverImageView.image = UIImage(named: "placeholder_artwork")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.coverImageView.layer.cornerRadius = coverImageCornerRadius
        self.coverImageView.image = nil
        self.albumTitleLabel.text = nil
        self.artistLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
