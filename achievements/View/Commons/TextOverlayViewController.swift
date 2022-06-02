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
    private var text : String = ""
    private var textView = UITextView()

    // MARK: View Lifecycle Methods
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        redisplay(to: size)
    }
    
    // MARK: Actions
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        self.vanish()
    }
    
    // MARK: Public Functions
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.9)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.addConstraints([
            NSLayoutConstraint(
                item: textView,
                attribute: NSLayoutConstraint.Attribute.width,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: nil,
                attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                multiplier: 1,
                constant: 300),
            NSLayoutConstraint(
                item: textView,
                attribute: NSLayoutConstraint.Attribute.height,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: nil,
                attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                multiplier: 1,
                constant: 300),
        ])
        
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    public func vanish() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    public func showOn(_ parentViewController: UIViewController?, text: String) {
        vanish()
        guard let viewController = parentViewController else { return }
        
        textView.text = text
        textView.font = .systemFont(ofSize: 15)
        textView.layer.cornerRadius = 5
        textView.isEditable = false
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView(_:))))
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView(_:))))
        
        viewController.addChild(self)
        view.frame = viewController.view.frame
        viewController.view.addSubview(view)
        didMove(toParent: viewController)
        
        viewController.view.setNeedsDisplay()
    }
    
    // MARK: Private Functions
    private func redisplay(to size: CGSize) {
        self.view.frame.size = size
        self.view.setNeedsDisplay()
    }
}
