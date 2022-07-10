//
//  BaseViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 01.06.22.
//

import UIKit

class BaseViewController: UIViewController {
    // MARK: Properties
    var onboardingKey : String? { return nil }

    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // -- Onboarding
        if(onboardingKey != nil) {
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle"), style: .plain, target: self, action: Selector("showOnboarding"))
            barButtonItem.accessibilityLabel = "onboardingButton"
            
            self.navigationItem.rightBarButtonItem = barButtonItem
        }
        // -- End of Onboarding
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // -- Onboarding
#if DEBUG
        // Do not display the onboarding automatically when in debug mode
#else
        if onboardingKey != nil && !(Settings.onboardingsShown[onboardingKey!] ?? false) {
            Settings.onboardingsShown[onboardingKey!] = true
            showOnboarding()
        }
#endif
        // -- End of Onboarding
    }
    
    // MARK: Private Functions
    @objc private func showOnboarding() {
        // -- Onboarding
        // Exceptions for Refactored TableViewControllers on which the Onboarding did not properly work
        let onboardingParentController : UIViewController?
        if self is StatisticsTableViewController {
            onboardingParentController = self.parent
        } else if self is HistoryTableViewController {
            onboardingParentController = self.parent
        } else {
            onboardingParentController = self
        }
        
        TextOverlayViewController().showOn(onboardingParentController, text: NSLocalizedString(onboardingKey!, tableName: "Onboardings", bundle: .main, comment: "Onboarding for View"))
        // -- End of Onboarding
    }
}
