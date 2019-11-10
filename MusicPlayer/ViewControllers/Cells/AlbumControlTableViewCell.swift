//
//  AlbumControlTableViewCell.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

protocol AlbumControlTableViewCellDelegate: NSObjectProtocol {
    func tapPlay()
    func tapShuffle()
}

final class AlbumControlTableViewCell: UITableViewCell {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    weak var delegate: AlbumControlTableViewCellDelegate?
    
    
    // MARK: - View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - IBAction Function
    
    @IBAction func onPlayButton(_ sender: UIButton) {
        self.delegate?.tapPlay()
    }
    
    @IBAction func onShuffleButton(_ sender: UIButton) {
        self.delegate?.tapShuffle()
    }
}
