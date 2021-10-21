//
//  DashboardController.swift
//  achievements
//
//  Created by Maximilian Schluer on 27.08.21.
//

import UIKit

class DashboardController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel!
    
    // MARK: Variables
    private var balance: Float = 0 {
        didSet {
            populateProgressWheel()
        }
    }
    private var progressWheelState = 0
    private var recentTransactions: [AchievementTransaction] = []
    private var recentTransactionsTableViewData: [Date: [AchievementTransaction]] = [:]
    private var recentTransactionsDates : [Date] = []
    
    // MARK: Outlets
    @IBOutlet weak var progressWheel: ProgressWheel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: View Lifecycle Methods
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
        switch segue.identifier {
        case "ShowHistorySegue":
            let destination = segue.destination as! HistoryTableViewController
            destination.achievementsDataModel = achievementsDataModel
        default:
            break
        }
    }

    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return recentTransactionsDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") {
            let transaction = getRecentTransactionFor(indexPath: indexPath)
            
            if transaction.amount < 0 {
                cell.backgroundColor = UIColor.systemRed
            } else {
                cell.backgroundColor = UIColor.systemGreen
            }
            
            if let label = cell.textLabel {
                label.text = (transaction.toString())
            }
            
            return cell
        }
        
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionCellPressed(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = recentTransactionsDates[section]
        let dictionaryEntry = recentTransactionsTableViewData[date]
        
        return dictionaryEntry?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Date Part
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let date = recentTransactionsDates[section]
        let datePart = formatter.string(for: date)
        
        // Balance Part
        let dictionaryItem = recentTransactionsTableViewData[date] ?? []
        let balance = calculateBalanceFor(array: dictionaryItem)
        
        return "\(datePart!) - ( \(String (format: "%.2f", balance)) )"
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: NSLocalizedString("Edit", comment: "Change Something")) { (action, view, completion) in
            self.transactionCellSwipeLeftEdit(indexPath)
            completion(true)
        }
        edit.backgroundColor = .systemYellow
        
        let delete = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Remove something (eg. from Database)")) { (action, view, completion) in
            self.transactionCellSwipeLeftDelete(indexPath)
            completion(false)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    
    // MARK: Action Handlers
    private func mainMenuAutoSettleButtonPressed() {
        Settings.applicationSettings.automaticPurge = !Settings.applicationSettings.automaticPurge
        if (Settings.applicationSettings.automaticPurge) {
            achievementsDataModel.purgeRecent()
            updateViewFromModel()
        }
        // Make sure to reflect the status in the autosettle-button
        setupMainMenu()
    }
    
    private func mainMenuHistoryButtonPressed() {
        performSegue(withIdentifier: "ShowHistorySegue", sender: menuButton)
    }
    
    private func mainMenuResetButtonPressed() {
        let deletionAlert = UIAlertController(title: NSLocalizedString("Sure?", comment: "Ask approval from the user"), message: NSLocalizedString("This will reset / clear all data and cannot be undone!", comment: "Make entirely clear that this will reset the entire Application"), preferredStyle: .actionSheet)
        deletionAlert.addAction(UIAlertAction(title: NSLocalizedString("Reset App", comment: "Action to set all data back to standard values."), style: .destructive, handler: { _ in
            self.resetApplication()
        }))
        deletionAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Abort current action."), style: .cancel, handler: nil))
        
        self.present(deletionAlert, animated: true)
    }
    
    private func mainMenuSettingsButtonPressed() {
        SettingsPresenter(achievementsDataModel: achievementsDataModel).showSettingsList(from: self)
    }
    
    private func mainMenuSettleButtonPressed() {
        achievementsDataModel.purgeRecent()
        updateViewFromModel()
    }
    
    private func mainMenuStatisticsButtonPressed() {
        StatisticsPresenter(achievementsDataModel: achievementsDataModel).takeOver(from: self)
    }
    
    @IBAction func progressWheelPressed(_ sender: Any) {
        progressWheelState = (progressWheelState + 1) % 4
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        populateProgressWheel()
    }
    
    @IBAction func toolbarAddButtonPressed(_ sender: Any) {
        AchievementTransactionsPresenter(achievevementsDataModel: achievementsDataModel).bookAchievementTransaction(from: self)
    }
    
    @IBAction func toolbarIncomeTemplatesButtonPressed(_ sender: Any) {
        TransactionTemplatesPresenter(achievementsDataModel: achievementsDataModel).showPlannedIncomes(from: self)
    }
    
    @IBAction func toolbarExpenseTemplatesButtonPressed(_ sender: Any) {
        TransactionTemplatesPresenter(achievementsDataModel: achievementsDataModel).showPlannedExpenses(from: self)
    }
    
    private func transactionCellPressed(_ indexPath: IndexPath) {
        AchievementTransactionsPresenter(achievevementsDataModel: achievementsDataModel).showTransactionDetails(from: self, transaction: getRecentTransactionFor(indexPath: indexPath))
    }
    
    private func transactionCellSwipeLeftEdit(_ indexPath: IndexPath) {
        AchievementTransactionsPresenter(achievevementsDataModel: achievementsDataModel).editTransaction(from: self, transaction: getRecentTransactionFor(indexPath: indexPath))
    }
    
    private func transactionCellSwipeLeftDelete(_ indexPath: IndexPath) {
        let transactionToDelete = getRecentTransactionFor(indexPath: indexPath).historicalTransaction!
        achievementsDataModel.remove(historicalTransaction: transactionToDelete)
        
        // Update Data
        recentTransactionsTableViewData = self.achievementsDataModel.groupedAchievementTransactions
        
        self.recentTransactionsTableView.deleteRows(at: [indexPath], with: .automatic)
        self.recalculateBalance()
    }
    
    // MARK: Setup Steps
    private func setupMainMenu() {
        let mainMenuDestruct = UIAction(title: NSLocalizedString("Reset", comment: "Set something back to initial state."), image: UIImage(systemName: "trash.circle"), attributes: .destructive) { _ in
            self.mainMenuResetButtonPressed() }
            
        var mainMenuItems = UIMenu(title: "mainMenu", options: .displayInline, children: [
            UIAction(title: NSLocalizedString("Settings", comment: "Menu item to get to the Configuration Menu"), image: UIImage(systemName: "gear"), handler: { _ in
                self.mainMenuSettingsButtonPressed()
            }),
            UIAction(title: NSLocalizedString("Settle automatically", comment: "Make sure to settle Transactions immediately after reaching the threshold."), image: UIImage(systemName: Settings.applicationSettings.automaticPurge ? "checkmark.square" : "square"), handler: { _ in
                self.mainMenuAutoSettleButtonPressed()
            }),
            UIAction(title: NSLocalizedString("Settle Transactions", comment: "Settle transactions against each other."), image: UIImage(systemName: "arrow.left.arrow.right.circle"), handler: { _ in
                self.mainMenuSettleButtonPressed()
            }),
            UIAction(title: NSLocalizedString("History", comment: "Things that happened so far."), image: UIImage(systemName: "clock.arrow.circlepath"), handler: { _ in
                self.mainMenuHistoryButtonPressed()
            }),
            UIAction(title: NSLocalizedString("Statistics", comment: "Data presented in visual form."), image: UIImage(systemName: "chart.bar"), handler: { _ in
                self.mainMenuStatisticsButtonPressed()
            })
        ])
        
        #if DEBUG
            menuButton.menu = UIMenu(title: "", children: [mainMenuItems, mainMenuDestruct])
        #else
            menuButton.menu = UIMenu(title: "", children: [mainMenuItems])
        #endif
    }
    
    private func setupTransactionTable() {
        self.recentTransactionsTableView.dataSource = self
        self.recentTransactionsTableView.delegate = self
        
        recentTransactions = achievementsDataModel.achievementTransactions
        recentTransactionsTableViewData = achievementsDataModel.groupedAchievementTransactions
    }
    
    // MARK: Private Functions
    private func calculateBalanceFor(array: [AchievementTransaction]) -> Float {
        var result : Float = 0.0
        
        for element in array {
            result += element.amount
        }
        
        return result
    }
    
    private func getRecentTransactionFor(indexPath: IndexPath) -> AchievementTransaction {
        let date = recentTransactionsDates[indexPath.section]
        let dictionaryEntry = recentTransactionsTableViewData[date]!
        return dictionaryEntry[indexPath.item]
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
            if let plannedExpense = achievementsDataModel.plannedExpenses.first {
                progressWheel.inactiveColor = UIColor.systemGray
                progressWheel.activeColor = UIColor.systemGreen
                let percentage = (achievementsDataModel.totalRecentIncomes / plannedExpense.amount) * -100
                
                if percentage <= 100 {
                    progressWheel.percentage = percentage
                } else {
                    progressWheel.percentage = 100
                }
            } else {
                progressWheel.inactiveColor = UIColor.systemGray
                progressWheel.activeColor = UIColor.systemGray
                progressWheel.percentage = 100
            }
        } else {
            progressWheel.inactiveColor = UIColor.systemRed
            progressWheel.activeColor = UIColor.systemGreen
            progressWheel.percentage = (achievementsDataModel.totalRecentIncomes / achievementsDataModel.recentExpenses.first!.amount) * -100
        }
    }
    
    private func recalculateBalance() {
        var newBalance : Float = 0;
        
        for transaction in recentTransactions {
            newBalance += transaction.amount
        }
        
        balance = newBalance
    }
    
    private func showCurrentRedemptionPercentageInProgressWheelLabel() {
        var percentage : Float = 0.0
        
        if achievementsDataModel.recentExpenses.first != nil {
            // Redeemable Recent Expense
            percentage = (achievementsDataModel.totalRecentIncomes / achievementsDataModel.recentExpenses.first!.amount) * -100
        } else if achievementsDataModel.plannedExpenses.first != nil {
            // Planned Expense
            percentage = (achievementsDataModel.totalRecentIncomes / achievementsDataModel.plannedExpenses.first!.amount) * -100
        }
        
        progressWheel.text = "\(String (format: "%.2f", percentage)) %"
        progressWheel.textColor = .systemGray
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
        var remainingAmount : Float = 0.0
        if achievementsDataModel.recentExpenses.count > 0 {
            // Redeemable Recent Expense
            remainingAmount = (achievementsDataModel.recentExpenses.first?.amount ?? 0.0 ) + achievementsDataModel.totalRecentIncomes
        } else if achievementsDataModel.plannedExpenses.count > 0 {
            // Planned Expense
            remainingAmount = (achievementsDataModel.plannedExpenses.first?.amount ?? 0.0) + achievementsDataModel.totalRecentIncomes
        }
        
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
    
    private func updateSections() {
        var result = Array(recentTransactionsTableViewData.keys)
        result.sort(by: >)
        
        self.recentTransactionsDates = result
    }
    
    private func updateViewFromModel() {
        recentTransactions = self.achievementsDataModel.achievementTransactions
        recentTransactionsTableViewData = self.achievementsDataModel.groupedAchievementTransactions
        updateSections()
        recentTransactionsTableView.reloadData()
        recalculateBalance()
    }
    
    // MARK: Destructive Actions
    private func resetApplication() {
        // Reset DataModel
        self.achievementsDataModel.clear()
        self.recentTransactions = self.achievementsDataModel.achievementTransactions
        self.recentTransactionsTableViewData = self.achievementsDataModel.groupedAchievementTransactions
        
        // Reset Settings
        Settings.resetApplicationSettings()
        
        updateViewFromModel()
        setupMainMenu()
    }
}