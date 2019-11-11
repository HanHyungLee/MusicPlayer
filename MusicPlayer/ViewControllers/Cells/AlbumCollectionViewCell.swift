//
//  AlbumCollectionViewCell.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

final class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    static let labelSize: CGFloat = 66.0
    
    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initCell(_ album: Album) {
        self.albumTitleLabel.text = album.albumTitle
        self.artistLabel.text = album.artistName
        if let artwork: UIImage = album.artwork {
            self.coverImageView.image = artwork
        }
        else {
            self.coverImageView.image = UIImage(named: "placeholder_artwork")
        }
    }
}
