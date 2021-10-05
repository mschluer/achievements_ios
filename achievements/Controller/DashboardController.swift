//
//  DashboardController.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.08.21.
//

import UIKit

class DashboardController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Persistence Models
    private let achievementsDataModel = AchievementsDataModel()
    
    // MARK: Variables
    private var balance: Float = 0 {
        didSet {
            populateProgressWheel()
        }
    }
    private var recentTransactionsTableViewData: [AchievementTransaction] = []
    
    // MARK: Outlets
    @IBOutlet weak var progressWheel: ProgressWheel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: Private Variables
    private var progressWheelState = 0
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainMenu()
        setupTransactionTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressWheelState = 0
        updateViewFromModel()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateTransactionFormSegue" {
            let destination = segue.destination as! TransactionFormController
            
            destination.achievementTransactionModel = achievementsDataModel
        } else if segue.identifier == "ShowHistorySegue" {
            let destination = segue.destination as! HistoryTableViewController
            
            destination.historicalTransactions = achievementsDataModel.historicalTransactions
        } else if segue.identifier == "ShowTransactionDetailViewSegue" {
            let destination = segue.destination as! TransactionDetailViewController
            
            destination.transaction = sender as? HistoricalTransaction
        } else if segue.identifier == "EditTransactionFormSegue" {
            let destination = segue.destination as! TransactionFormController
            
            destination.achievementTransaction = (sender as! AchievementTransaction)
            destination.achievementTransactionModel = achievementsDataModel
        } else if segue.identifier == "ShowTemplatesViewSegue" {
            let destination = segue.destination as! TransactionTemplatesViewController
            
            destination.achievementsDataModel = achievementsDataModel
        } else if segue.identifier == "ShowStatisticsViewSegue" {
            let destination = segue.destination as! StatisticsViewController
            
            destination.achievementsDataModel = achievementsDataModel
        }
    }

    // MARK: Table View Data Source
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionCellPressed(indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Löschen") { (action, view, completion) in
            self.transactionCellSwipeLeft(indexPath)
            completion(false)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Bearbeiten") { (action, view, completion) in
            self.transactionCellSwipeRight(indexPath)
            completion(true)
        }
        edit.backgroundColor = .systemYellow
        
        let config = UISwipeActionsConfiguration(actions: [edit])
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    
    // MARK: Action Handlers
    @IBAction func progressWheelPressed(_ sender: Any) {
        progressWheelState = (progressWheelState + 1) % 4
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        populateProgressWheel()
    }
    
    private func mainMenuResetButtonPressed() {
        let deletionAlert = UIAlertController(title: "Sicher?", message: "Der Reset setzt alle Daten der App zurück. Dies kann nicht rückgängig gemacht werden!", preferredStyle: .actionSheet)
        deletionAlert.addAction(UIAlertAction(title: "App Zurücksetzen", style: .destructive, handler: { _ in
            self.resetApplication()
        }))
        deletionAlert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        
        self.present(deletionAlert, animated: true)
    }
    
    private func mainMenuSettleButtonPressed() {
        achievementsDataModel.purgeRecent()
        updateViewFromModel()
    }
    
    private func mainMenuHistoryButtonPressed() {
        performSegue(withIdentifier: "ShowHistorySegue", sender: menuButton)
    }
    
    private func mainMenuStatisticsButtonPressed() {
        performSegue(withIdentifier: "ShowStatisticsViewSegue", sender: menuButton)
    }
    
    private func transactionCellPressed(_ indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowTransactionDetailViewSegue", sender: recentTransactionsTableViewData[indexPath.row].historicalTransaction)
    }
    
    private func transactionCellSwipeRight(_ indexPath: IndexPath) {
        performSegue(withIdentifier: "EditTransactionFormSegue", sender: recentTransactionsTableViewData[indexPath.row])
    }
    
    private func transactionCellSwipeLeft(_ indexPath: IndexPath) {
        achievementsDataModel.remove(historicalTransaction: recentTransactionsTableViewData[indexPath.row].historicalTransaction!)
        recentTransactionsTableViewData = self.achievementsDataModel.achievementTransactions
        
        self.recentTransactionsTableView.deleteRows(at: [indexPath], with: .automatic)
        self.recalculateBalance()
    }
    
    // MARK: Setup Steps
    private func setupTransactionTable() {
        self.recentTransactionsTableView.dataSource = self
        self.recentTransactionsTableView.delegate = self
        
        recentTransactionsTableViewData = achievementsDataModel.achievementTransactions
    }
    
    private func setupMainMenu() {
        let mainMenuDestruct = UIAction(title: "Reset", image: UIImage(systemName: "trash.circle"), attributes: .destructive) { _ in
            self.mainMenuResetButtonPressed() }
            
        let mainMenuItems = UIMenu(title: "mainMenu", options: .displayInline, children: [
            UIAction(title: "Transaktionen Verrechnen", image: UIImage(systemName: "arrow.left.arrow.right.circle"), handler: { _ in
                self.mainMenuSettleButtonPressed()
            }),
            UIAction(title: "Historie", image: UIImage(systemName: "clock.arrow.circlepath"), handler: { _ in
                self.mainMenuHistoryButtonPressed()
            }),
            UIAction(title: "Statistiken", image: UIImage(systemName: "chart.bar"), handler: { _ in
                self.mainMenuStatisticsButtonPressed()
            })
        ])
        menuButton.menu = UIMenu(title: "", children: [mainMenuItems, mainMenuDestruct])
    }
    
    // MARK: Private Functions
    private func updateViewFromModel() {
        recentTransactionsTableViewData = self.achievementsDataModel.achievementTransactions
        recentTransactionsTableView.reloadData()
        recalculateBalance()
    }
    
    private func populateProgressWheel() {
        switch progressWheelState {
        case 1:
            showTotalRecentIncomesInProgressWheelLabel()
        case 2:
            showRemainingExpenseAmountInProgressWheelLabel()
        case 3:
            showCurrentRedemptionPercentageInProgressWheelLabel()
        default:
            showTotalBalanceInProgressWheelLabel()
        }
        
        // Update Progress Wheel
        if(balance >= 0) {
            progressWheel.inactiveColor = UIColor.systemGray
            progressWheel.activeColor = UIColor.systemGray
            progressWheel.percentage = 100
        } else {
            progressWheel.inactiveColor = UIColor.systemRed
            progressWheel.activeColor = UIColor.systemGreen
            progressWheel.percentage = (achievementsDataModel.totalRecentIncomes / achievementsDataModel.recentExpenses.first!.amount) * -100
        }
    }
    
    private func showTotalBalanceInProgressWheelLabel() {
        if balance < 0 {
            progressWheel.text = "\(String (format: "%.2f", balance))"
            progressWheel.textColor = .systemRed
        } else if balance == 0 {
            progressWheel.text = "+/- \(String (format: "%.2f", balance))"
            progressWheel.textColor = .systemGray
        } else {
            progressWheel.text = "+\(String (format: "%.2f", balance))"
            progressWheel.textColor = .systemGreen
        }
    }
    
    private func showTotalRecentIncomesInProgressWheelLabel() {
        progressWheel.text = "(+\(String (format: "%.2f", achievementsDataModel.totalRecentIncomes)))"
        progressWheel.textColor = .systemGreen
    }
    
    private func showRemainingExpenseAmountInProgressWheelLabel() {
        let remainingAmount = (achievementsDataModel.recentExpenses.first?.amount ?? 0.0 ) + achievementsDataModel.totalRecentIncomes
        
        if remainingAmount < 0 {
            progressWheel.text = "(\(String (format: "%.2f", remainingAmount)))"
            progressWheel.textColor = .systemRed
        } else if remainingAmount == 0 {
            progressWheel.text = "(+/- \(String (format: "%.2f", remainingAmount)))"
            progressWheel.textColor = .systemGray
        } else {
            progressWheel.text = "(+\(String (format: "%.2f", remainingAmount)))"
            progressWheel.textColor = .systemGreen
        }
    }
    
    private func showCurrentRedemptionPercentageInProgressWheelLabel() {
        var percentage : Float = 0.0
        if(achievementsDataModel.recentExpenses.first != nil) {
            percentage = (achievementsDataModel.totalRecentIncomes / achievementsDataModel.recentExpenses.first!.amount) * -100
        }
        
        progressWheel.text = "\(String (format: "%.2f", percentage)) %"
        progressWheel.textColor = .systemGray
    }
    
    private func recalculateBalance() {
        var newBalance : Float = 0;
        
        for transaction in recentTransactionsTableViewData {
            newBalance += transaction.amount
        }
        
        balance = newBalance
    }
    
    private func resetApplication() {
        self.achievementsDataModel.clear()
        self.recentTransactionsTableViewData = self.achievementsDataModel.achievementTransactions
        
        updateViewFromModel()
    }
}
