//
//  DashboardController.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.08.21.
//

import UIKit

class DashboardController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Persistence Models
    private let achievementsTransactionsModel = AchievementsTransactionsModel()
    
    // MARK: Variables
    private var balance: Float = 0 {
        didSet {
            if balance < 0 {
                balanceLabel.text = "\(String (format: "%.2f", balance))"
                balanceLabel.textColor = .systemRed
            } else if balance == 0 {
                balanceLabel.text = "+/- \(String (format: "%.2f", balance))"
                balanceLabel.textColor = .none
            } else {
                balanceLabel.text = "+\(String (format: "%.2f", balance))"
                balanceLabel.textColor = .systemGreen
            }
        }
    }
    private var recentTransactionsTableViewData: [AchievementTransaction] = [] {
        didSet {
            recentTransactionsTableView.reloadData()
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTransactionTable()
        recalculateBalance()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateTransactionFormSegue" {
            let destination = segue.destination as! TransactionFormController
            
            destination.achievementTransaction = achievementsTransactionsModel.createAchievementTransaction()
            destination.achievementsTransactionsModel = achievementsTransactionsModel
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    // MARK: Table View Functionalities
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentTransactionsTableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") {
            if recentTransactionsTableViewData[indexPath.item].amount < 0 {
                cell.backgroundColor = UIColor.systemRed
            } else {
                cell.backgroundColor = UIColor.systemGreen
            }
            
            if let label = cell.textLabel {
                label.text = (recentTransactionsTableViewData[indexPath.item].toString())
            }
            
            return cell
        }
        
        return UITableViewCell();
    }
    
    private func mainMenuDeletionButtonPressed() {
        let deletionAlert = UIAlertController(title: "Are you sure?", message: "Reset deletes all your data including historical transactions, templates and settings. Only do this is you are entirely sure what you are doing!", preferredStyle: .actionSheet)
        deletionAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.resetApplication()
        }))
        deletionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(deletionAlert, animated: true)
    }
    
    // MARK: Setup Steps
    private func setupTransactionTable() {
        recentTransactionsTableViewData = achievementsTransactionsModel.achievementTransactions
        self.recentTransactionsTableView.dataSource = self
        self.recentTransactionsTableView.delegate = self
    }
    
    private func setupMainMenu() {
        let mainMenuDestruct = UIAction(title: "Reset", image: UIImage(systemName: "trash.circle"), attributes: .destructive) { _ in
            self.mainMenuDeletionButtonPressed() }
            
        let mainMenuItems = UIMenu(title: "Main Menu", options: .displayInline, children: [
            UIAction(title: "Transaktionen Verrechnen", image: UIImage(systemName: "arrow.left.arrow.right.circle"), handler: { _ in }),
            UIAction(title: "Historie", image: UIImage(systemName: "clock.arrow.circlepath"), handler: { _ in }),
            UIAction(title: "Statistiken", image: UIImage(systemName: "chart.bar"), handler: { _ in })
        ])
        menuButton.menu = UIMenu(title: "", children: [mainMenuItems, mainMenuDestruct])
    }
    
    // MARK: Private Functions
    private func recalculateBalance() {
        var newBalance : Float = 0;
        
        for transaction in recentTransactionsTableViewData {
            newBalance += transaction.amount
        }
        
        balance = newBalance
    }
    
    private func resetApplication() {
        self.achievementsTransactionsModel.clear()
        self.recentTransactionsTableViewData = self.achievementsTransactionsModel.achievementTransactions
        self.recalculateBalance()
    }
}
