//
//  TextOverlayViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 09.05.22.
//

import Foundation
import UIKit

class TextOverlayViewController : UIViewController {
    // MARK: Private Variables
    private var parentInputViewController : UIInputViewController?
    private var label = UILabel()
    
    
    // MARK: Actions
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        self.vanish()
    }
    
    // MARK: Public Functions
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.9)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.addConstraints([
            NSLayoutConstraint(
                item: label,
                attribute: NSLayoutConstraint.Attribute.width,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: nil,
                attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                multiplier: 1,
                constant: 300),
            NSLayoutConstraint(
                item: label,
                attribute: NSLayoutConstraint.Attribute.height,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: nil,
                attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                multiplier: 1,
                constant: 500),
        ])
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    public func vanish() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    public func showOn(_ parentInputViewController: UIViewController?, text: String) {
        vanish()
        guard let viewController = parentInputViewController else { return }
        
        label.text = text
        label.numberOfLines = 0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        viewController.addChild(self)
        view.frame = viewController.view.frame
        viewController.view.addSubview(view)
        didMove(toParent: viewController)
        
        viewController.view.setNeedsDisplay()
    }
}
