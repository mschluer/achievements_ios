//
//  StatisticsViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 05.09.21.
//

import UIKit

class StatisticsViewController: UIViewController {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    
    // MARK: Variables
    
    // MARK: Outlets
    @IBOutlet weak var totalRecentIncomesLabel: UILabel!
    @IBOutlet weak var totalRecentExpensesLabel: UILabel!
    @IBOutlet weak var amountRecentIncomesLabel: UILabel!
    @IBOutlet weak var amountRecentExpensesLabel: UILabel!
    @IBOutlet weak var totalIncomesLabel: UILabel!
    @IBOutlet weak var totalExpensesLabel: UILabel!
    @IBOutlet weak var amountIncomesLabel: UILabel!
    @IBOutlet weak var amountExpensesLabel: UILabel!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupRecentStatistics()
        self.setupHistoricalStatistics()
    }
    
    // MARK: Setup Steps
    private func setupRecentStatistics() {
        if let model = achievementsDataModel {
            totalRecentIncomesLabel.text = String(format: "%.2f", model.totalRecentIncomes)
            totalRecentExpensesLabel.text = String(format: "%.2f", model.totalRecentExpenses)
            amountRecentIncomesLabel.text = "\(model.recentIncomes.count)"
            amountRecentExpensesLabel.text = "\(model.recentExpenses.count)"
        }
    }
    
    private func setupHistoricalStatistics() {
        if let model = achievementsDataModel {
            totalIncomesLabel.text = String(format: "%.2f", model.totalHistoricalIncomes)
            totalExpensesLabel.text = String(format: "%.2f", model.totalHistoricalExpenses)
            amountIncomesLabel.text = "\(model.historicalIncomes.count)"
            amountExpensesLabel.text = "\(model.historicalExpenses.count)"
        }
    }
    
    // MARK: Private Functions
}
