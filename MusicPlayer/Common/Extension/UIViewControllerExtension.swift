//
//  UIViewControllerExtension.swift
//  MusicPlayer
//
//  Created by Hanhyung Lee on 2019/11/10.
//  Copyright © 2019 Hanhyung Lee. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(_ text: String, ok: String, completion: (() -> ())?) {
        let alertController =
            UIAlertController(title: "알림",
                              message: text,
                              preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: ok, style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
