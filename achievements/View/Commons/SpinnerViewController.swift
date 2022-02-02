//
//  SpinnerViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.01.22.
//

import UIKit

// Taken from
// https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening
class SpinnerViewController : UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)

        override func loadView() {
            view = UIView()
            view.backgroundColor = UIColor(white: 0.5, alpha: 0.7)

            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            view.addSubview(spinner)

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
}
