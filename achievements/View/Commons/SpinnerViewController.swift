//
//  SpinnerViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.01.22.
//

import UIKit

// Originally Taken from
// https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening

class SpinnerViewController : UIViewController {
    // MARK: Public Variables
    var spinner = UIActivityIndicatorView(style: .large)
    
    // MARK: Private Variables
    private var parentInputViewController : UIInputViewController?

    
    // MARK: Public Function
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    public func vanish() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    public func showOn(_ parentInputViewController: UIViewController?) {
        vanish()
        guard let viewController = parentInputViewController else { return }
        
        viewController.addChild(self)
        view.frame = viewController.view.frame
        viewController.view.addSubview(view)
        didMove(toParent: viewController)
        
        viewController.view.setNeedsDisplay()
    }
    
    public func showOn(_ parentView: UIView) {
        vanish()
        
        view.frame = parentView.frame
        parentView.addSubview(view)
    }
}
