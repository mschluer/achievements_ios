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
    private var emptyScreenLabel : UILabel?
    private var progressWheelState = 0
    private var recentTransactions: [AchievementTransaction] = []
    private var recentTransactionsTableViewData: [DateComponents: [AchievementTransaction]] = [:]
    private var recentTransactionsDates : [DateComponents] = []
    
    // MARK: Outlets
    @IBOutlet weak var expenseTemplatesButton: UIBarButtonItem!
    @IBOutlet weak var incomeTemplatesButton: UIBarButtonItem!
    @IBOutlet weak var progressWheel: ProgressWheel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: Onboarding
    var onboardingKey = "dashboard"
    var onboardingText = NSLocalizedString("Welcome to the Achievements App!\n\nThis is the central view of the app, showing the progress wheel on top, the most recent turnovers grouped by day and controls at the bottom.\n\nSwiping right on a turnover duplicates it.\nBy swiping left they can be edited or deleted.\n\nBelow, the +-icon leads to the 'new Turnover'-dialogue. The folder icons lead to the templates for incomes and expenses. The three lines icon lead to the menu.", comment: "Onboarding for the Dashboard")
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainMenu()
        setupTransactionTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        progressWheelState = 0
        updateViewFromModel()
        
        setupExpenseConvenienceMenu()
        setupIncomeConvenienceMenu()
        
        // Onboarding
        if(!(Settings.onboardingsShown[onboardingKey] ?? false)) {
            // Settings.onboardingsShown[onboardingKey] = true
            TextOverlayViewController().showOn(self, text: onboardingText)
        }
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
        } else {
            return UITableViewCell();
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionCellPressed(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateComponents = recentTransactionsDates[section]
        let dictionaryEntry = recentTransactionsTableViewData[dateComponents]
        
        return dictionaryEntry?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Date Part
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let date = Calendar.current.date(from: recentTransactionsDates[section])!
        let dateComponents = recentTransactionsDates[section]
        let datePart = formatter.string(for: date)
        
        // Balance Part
        let dictionaryItem = recentTransactionsTableViewData[dateComponents] ?? []
        let balance = calculateBalanceFor(array: dictionaryItem)
        
        return "\(datePart!) - ( \(NumberHelper.formattedString(for: balance)) )"
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let duplicate = UIContextualAction(style: .normal, title: NSLocalizedString("Duplicate", comment: "Duplicate transaction")) { (action, view, completion) in
            self.transactionCellSwipeRightDuplicate(indexPath)
            completion(false)
        }
        duplicate.backgroundColor = .systemTeal
        
        let config = UISwipeActionsConfiguration(actions: [duplicate])
        config.performsFirstActionWithFullSwipe = true
        
        return config
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
    
    private func templateConvenienceMenuButtonPressed(transactionTemplate template: TransactionTemplate) {
        _ = self.achievementsDataModel?.createAchievementTransactionWith(
            text: template.text!,
            amount: template.amount,
            date: Date())
        
        if(!template.recurring) {
            achievementsDataModel?.remove(transactionTemplate: template)
        }
        
        // Refresh
        updateViewFromModel()
        setupExpenseConvenienceMenu()
        setupIncomeConvenienceMenu()
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
        self.updateViewFromModel()
        self.updateEmptyScreenState()
    }
    
    private func transactionCellSwipeRightDuplicate(_ indexPath: IndexPath) {
        let achievementTransaction = getRecentTransactionFor(indexPath: indexPath)
        
        _ = achievementsDataModel.createAchievementTransactionWith(text: achievementTransaction.text!, amount: achievementTransaction.amount, date: Date())
        updateViewFromModel()
    }
    
    // MARK: Setup Steps
    private func setupExpenseConvenienceMenu() {
        guard let expenseTemplatesButton = self.expenseTemplatesButton else { return }
        
        let nonRecurringExpensesTemplates = achievementsDataModel.nonRecurringExpenseTemplates
        let recurringExpensesTemplates = achievementsDataModel.recurringExpenseTemplates
        
        var recurringSectionMenuItems : [UIAction] = []
        for i in 0...4 {
            if(i >= recurringExpensesTemplates.count) { break }
            
            let currentTemplate = recurringExpensesTemplates[i]
            
            if(currentTemplate.isQuickBookable()) {
                recurringSectionMenuItems.append(
                    UIAction(title: "\(currentTemplate.text!) (\(NumberHelper.formattedString(for: currentTemplate.amount)))",
                             image: nil,
                             handler: { _ in
                                 self.templateConvenienceMenuButtonPressed(transactionTemplate: currentTemplate)
                             }))
            }
        }
        let recurringSection = UIMenu(title: "", options: .displayInline, children:recurringSectionMenuItems)
        
        var nonRecurringSectionMenuItems : [UIAction] = []
        if let nonRecurringExpenseTemplate = nonRecurringExpensesTemplates.first {
            if(nonRecurringExpenseTemplate.isQuickBookable()) {
                
                nonRecurringSectionMenuItems.append(
                    UIAction(title: "\(nonRecurringExpenseTemplate.text!) (\(NumberHelper.formattedString(for: nonRecurringExpenseTemplate.amount)))",
                             image: nil,
                             handler: { _ in
                                 self.templateConvenienceMenuButtonPressed(transactionTemplate: nonRecurringExpenseTemplate)
                             }))
            }
        }
        let nonRecurringSection = UIMenu(title: "", options: .displayInline, children: nonRecurringSectionMenuItems)
        
        
        if (nonRecurringSectionMenuItems.count == 0 && recurringSectionMenuItems.count == 0) {
            expenseTemplatesButton.menu = nil
        } else {
            if(nonRecurringSectionMenuItems.count == 0) {
                expenseTemplatesButton.menu = UIMenu(title: "", children: [ recurringSection ])
            } else if (recurringSectionMenuItems.count == 0) {
                expenseTemplatesButton.menu  = UIMenu(title: "", children: [ nonRecurringSection ])
            } else {
                expenseTemplatesButton.menu = UIMenu(title: "", children: [ recurringSection, nonRecurringSection ])
            }
        }
    }
    
    private func setupIncomeConvenienceMenu() {
        guard let incomeTemplatesButton = self.incomeTemplatesButton else { return }
        
        let nonRecurringIncomesTemplates = achievementsDataModel.nonRecurringIncomeTemplates
        let recurringIncomesTemplates = achievementsDataModel.recurringIncomeTemplates
        
        var recurringSectionMenuItems : [UIAction] = []
        for i in 0...4 {
            if(i >= recurringIncomesTemplates.count) { break }
            
            let currentTemplate = recurringIncomesTemplates[i]
            
            if(currentTemplate.isQuickBookable()) {
                recurringSectionMenuItems.append(
                    UIAction(title: "\(currentTemplate.text!) (\(NumberHelper.formattedString(for: currentTemplate.amount)))",
                             image: nil,
                             handler: { _ in
                                 self.templateConvenienceMenuButtonPressed(transactionTemplate: currentTemplate)
                             }))
            }
        }
        let recurringSection = UIMenu(title: "", options: .displayInline, children:recurringSectionMenuItems)
        
        var nonRecurringSectionMenuItems : [UIAction] = []
        if let nonRecurringIncomeTemplate = nonRecurringIncomesTemplates.first {
            if(nonRecurringIncomeTemplate.isQuickBookable()) {
                
                nonRecurringSectionMenuItems.append(
                    UIAction(title: "\(nonRecurringIncomeTemplate.text!) (\(NumberHelper.formattedString(for: nonRecurringIncomeTemplate.amount)))",
                             image: nil,
                             handler: { _ in
                                 self.templateConvenienceMenuButtonPressed(transactionTemplate: nonRecurringIncomeTemplate)
                             }))
            }
        }
        let nonRecurringSection = UIMenu(title: "", options: .displayInline, children: nonRecurringSectionMenuItems)
        
        
        if (nonRecurringSectionMenuItems.count == 0 && recurringSectionMenuItems.count == 0) {
            incomeTemplatesButton.menu = nil
        } else {
            if(nonRecurringSectionMenuItems.count == 0) {
                incomeTemplatesButton.menu = UIMenu(title: "", children: [ recurringSection ])
            } else if (recurringSectionMenuItems.count == 0) {
                incomeTemplatesButton.menu  = UIMenu(title: "", children: [ nonRecurringSection ])
            } else {
                incomeTemplatesButton.menu = UIMenu(title: "", children: [ recurringSection, nonRecurringSection ])
            }
        }
        
    }
    
    private func setupMainMenu() {
        guard let menuButton = self.menuButton else { return }
        
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
        let dateComponents = recentTransactionsDates[indexPath.section]
        let dictionaryEntry = recentTransactionsTableViewData[dateComponents]!
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
            if let plannedExpense = achievementsDataModel.expenseTemplates.first {
                progressWheel.inactiveColor = UIColor.systemGray
                progressWheel.activeColor = UIColor.systemGreen
                let percentage = (balance / plannedExpense.amount) * -100
                
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
        } else if achievementsDataModel.expenseTemplates.first != nil {
            // Planned Expense
            percentage = (achievementsDataModel.totalRecentIncomes / achievementsDataModel.expenseTemplates.first!.amount) * -100
        }
        
        // Make sure not to show more than 100 %
        if percentage > 100 {
            percentage = 100
        }
        
        progressWheel.text = "\(NumberHelper.formattedString(for: percentage)) %"
        progressWheel.textColor = .systemGray
    }
    
    private func showTotalBalanceInProgressWheelLabel() {
        if balance < 0 {
            progressWheel.text = "\(NumberHelper.formattedString(for: balance))"
            progressWheel.textColor = .systemRed
        } else if balance == 0 {
            progressWheel.text = "+/- \(NumberHelper.formattedString(for: balance))"
            progressWheel.textColor = .systemGray
        } else {
            progressWheel.text = "+\(NumberHelper.formattedString(for: balance))"
            progressWheel.textColor = .systemGreen
        }
    }
    
    private func showTotalRecentIncomesInProgressWheelLabel() {
        progressWheel.text = "(+\(NumberHelper.formattedString(for: achievementsDataModel.totalRecentIncomes)))"
        progressWheel.textColor = .systemGreen
    }
    
    private func showRemainingExpenseAmountInProgressWheelLabel() {
        var remainingAmount : Float = 0.0
        if achievementsDataModel.recentExpenses.count > 0 {
            // Redeemable Recent Expense
            remainingAmount = (achievementsDataModel.recentExpenses.first?.amount ?? 0.0 ) + achievementsDataModel.totalRecentIncomes
        } else if achievementsDataModel.expenseTemplates.count > 0 {
            // Planned Expense
            remainingAmount = (achievementsDataModel.expenseTemplates.first?.amount ?? 0.0) + achievementsDataModel.totalRecentIncomes
        }
        
        if remainingAmount < 0 {
            progressWheel.text = "(\(NumberHelper.formattedString(for: remainingAmount)))"
            progressWheel.textColor = .systemRed
        } else if remainingAmount == 0 {
            progressWheel.text = "(+/- \(NumberHelper.formattedString(for: remainingAmount)))"
            progressWheel.textColor = .systemGray
        } else {
            progressWheel.text = "(+\(NumberHelper.formattedString(for: remainingAmount)))"
            progressWheel.textColor = .systemGreen
        }
    }
    
    private func updateEmptyScreenState() {
        if(recentTransactionsTableViewData.isEmpty) {
            if(emptyScreenLabel != nil) { return }
            
            let label = UILabel()
            label.text = NSLocalizedString("Nothing to show.\n\nAdd Transactions with the + button in the bottom left hand corner or by using Templates, which can accessed with the folder-buttons.", comment: "Description for empty Dashboard")
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.addConstraints([
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutConstraint.Attribute.width,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: nil,
                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                    multiplier: 1,
                    constant: 200),
                NSLayoutConstraint(
                    item: label,
                    attribute: NSLayoutConstraint.Attribute.height,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: nil,
                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                    multiplier: 1,
                    constant: 200),
            ])
            
            self.recentTransactionsTableView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: recentTransactionsTableView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: recentTransactionsTableView.centerYAnchor).isActive = true
            
            self.emptyScreenLabel = label
        } else {
            if let label = self.emptyScreenLabel {
                label.removeFromSuperview()
                self.emptyScreenLabel = nil
            }
        }
    }
    
    private func updateSections() {
        var result = Array(recentTransactionsTableViewData.keys)
        result.sort(by: { Calendar.current.date(from: $0)! > Calendar.current.date(from: $1)! })
        
        self.recentTransactionsDates = result
    }
    
    private func updateViewFromModel() {
        recentTransactions = self.achievementsDataModel.achievementTransactions
        recentTransactionsTableViewData = self.achievementsDataModel.groupedAchievementTransactions
        updateSections()
        recentTransactionsTableView.reloadData()
        recalculateBalance()
        updateEmptyScreenState()
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
        setupExpenseConvenienceMenu()
        setupIncomeConvenienceMenu()
    }
}
