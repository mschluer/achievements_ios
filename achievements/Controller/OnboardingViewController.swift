//
//  OnboardingViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 01.06.22.
//

import UIKit

class OnboardingViewController: UIViewController {
    // MARK: Properties
    var onboardingKey : String? { return nil }

    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if(onboardingKey != nil) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle"), style: .plain, target: self, action: Selector(("showOnboarding")))
        } else {
            print("WARNING: Onboarding key for view is not set although class \(String(describing: self)) is an OnboardingViewController")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
#if DEBUG
        // Do not display the onboarding automatically when in debug mode
#else
        if(onboardingKey != nil) {
            if(!(Settings.onboardingsShown[onboardingKey!] ?? false)) {
                Settings.onboardingsShown[onboardingKey!] = true
                showOnboarding()
            }
        }
#endif
    }
    
    // MARK: Private Functions
    @objc private func showOnboarding() {
        TextOverlayViewController().showOn(self.parent, text: NSLocalizedString(onboardingKey!, tableName: "Onboardings", bundle: .main, comment: "Onboarding for View"))
    }
}
