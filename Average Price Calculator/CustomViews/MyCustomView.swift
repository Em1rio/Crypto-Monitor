//
//  MyCustomView.swift
//  Average Price Calculator
//
//  Created by Emir Nasyrov on 10.12.2022.
//

import UIKit



    
    class MyCustomView: UIView {

        @IBInspectable var borderWidth: CGFloat = 0 {
            didSet {
                layer.borderWidth = borderWidth
            }
        }
        @IBInspectable var borderColor: UIColor? {
            didSet {
                layer.borderColor = borderColor?.cgColor
            }
        }
        
    }


