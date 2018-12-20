//
//  AVPlayerView.swift
//  NewsApp
//
//  Created by Jayashree on 20/12/18.
//  Copyright © 2018 Fafadia Tech. All rights reserved.
//

import UIKit
import AVFoundation
class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
