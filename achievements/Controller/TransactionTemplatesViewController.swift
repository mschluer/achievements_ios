//
//  TransactionTemplateViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 04.09.21.
//

import UIKit

class TransactionTemplatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?

    // MARK: Outlets
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    // MARK: Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: Action Handlers
    
    // MARK: Setup Steps
    
    // MARK: Private Functions
}
