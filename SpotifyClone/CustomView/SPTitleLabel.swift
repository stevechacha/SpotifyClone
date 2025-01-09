//
//  SPTitleLabel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//

import UIKit

class SPTitleLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(textAlignment: NSTextAlignment,fontSize: CGFloat){
        super.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = UIFont.systemFont(ofSize: fontSize,weight: .bold)
        configure()
        
    }
    
    private func configure(){
        textColor = .label
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.9
        lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
    }

}
