//
//  TransactionTemplatesListViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 04.09.21.
//

import UIKit
import CoreData

class TransactionTemplatesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    public var displayMode : TransactionTemplatesListMode = .incomes // TODO: Remove this default
    
    // MARK: Variables
    private var emptyScreenLabel : UILabel?
    private var templatesTableData : [String : [TransactionTemplate]] = [:]
    private var templatesTableSections : [String] = []

    // MARK: Outlets
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var templatesTable: UITableView!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if displayMode == .incomes {
            self.navigationItem.title = NSLocalizedString("Planned Incomes", comment: "Navigation Item Title for Planned Incomes")
        } else {
            self.navigationItem.title = NSLocalizedString("Planned Expenses", comment: "Navigation Item Title for Planned Expenses")
        }
        
        setupSortMenu()
        setupTemplatesTable()
        
        templatesTable.dragInteractionEnabled = true
        templatesTable.dragDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewFromModel()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AddTransactionTemplateFormSegue":
            let destination = segue.destination as! TransactionTemplateFormController
            destination.achievementsDataModel = achievementsDataModel
            displayMode == .expenses ? (destination.flipSignOnShow = true) : (destination.flipSignOnShow = false)
        case "EditTransactionTemplateSegue":
            let destination = segue.destination as! TransactionTemplateFormController
            destination.achievementsDataModel = achievementsDataModel
            destination.transactionTemplate = (sender as! TransactionTemplate)
        default:
            break
        }
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        if(displayMode == .incomes) {
            return Settings.applicationSettings.divideIncomeTemplatesByRecurrence ? 2 : 1
        } else {
            return Settings.applicationSettings.divideExpenseTemplatesByRecurrence ? 2 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell") {
            let template = transactionTemplateFor(indexPath: indexPath)
            
            // Populate Cell
            cell.textLabel?.text = template.text
            if template.amount < 0 {
                cell.detailTextLabel?.textColor = UIColor.systemRed
                cell.detailTextLabel?.text = NumberHelper.formattedString(for: template.amount)
            } else if template.amount > 0 {
                cell.detailTextLabel?.textColor = UIColor.systemGreen
                cell.detailTextLabel?.text = NumberHelper.formattedString(for: template.amount)
            } else {
                cell.detailTextLabel?.text = ""
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionTemplateCellPressed(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = transactionTemplateFor(indexPath: indexPath)
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard transactionTemplateFor(indexPath: indexPath).isQuickBookable() else {
            return nil
        }
        
        let book = UIContextualAction(style: .normal, title: NSLocalizedString("Book", comment: "Take Transaction Template into effect.")) { (action, view, completion) in
            self.swipeRightQuickBook(at: indexPath)
            completion(false)
        }
        book.backgroundColor = .systemGreen
        
        let config = UISwipeActionsConfiguration(actions: [book])
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceKey = templatesTableSections[sourceIndexPath.section]
        var sourceDictionaryEntry = templatesTableData[sourceKey]!
        let item : TransactionTemplate
        if sourceIndexPath.section == destinationIndexPath.section {
            // Re-Arrange item
            item = sourceDictionaryEntry.remove(at: sourceIndexPath.item)
            sourceDictionaryEntry.insert(item, at: destinationIndexPath.item)
            
            // Reindex Dictionary Entry
            for i in 0...sourceDictionaryEntry.count - 1 {
                sourceDictionaryEntry[i].orderIndex = Int16(i)
            }
        } else {
            let destinationKey = templatesTableSections[destinationIndexPath.section]
            var destinationDictionaryEntry = templatesTableData[destinationKey]!
            
            // Re-Arrange item
            item = sourceDictionaryEntry.remove(at: sourceIndexPath.item)
            destinationDictionaryEntry.insert(item, at: destinationIndexPath.item)
            
            // Reindex Dictionary Entry
            for i in 0...destinationDictionaryEntry.count - 1 {
                destinationDictionaryEntry[i].orderIndex = Int16(i)
            }
            
            // Flip Recurring Flag
            item.recurring = !item.recurring
        }
        
        achievementsDataModel?.save()
        refreshData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = templatesTableSections[section]
        return templatesTableData[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(self.templatesTable, numberOfRowsInSection: section) > 0  && templatesTableSections.count != 1 {
            return templatesTableSections[section]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: NSLocalizedString("Edit", comment: "Change Something")) { (action, view, completion) in
            self.swipeLeftEdit(at: indexPath)
            completion(false)
        }
        edit.backgroundColor = .systemYellow
        
        let delete = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Remove something (eg. from Database)")) { (action, view, completion) in
            self.swipeLeftDelete(at: indexPath)
            completion(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return config
    }
    
    // MARK: Action Handlers
    private func sortMenuSortAlphabeticallyButtonPressed() {
        if(displayMode == .incomes) {
            achievementsDataModel?.sortIncomeTemplates(by: [ NSSortDescriptor(key: "text", ascending: true) ])
        } else {
            achievementsDataModel?.sortExpenseTemplates(by: [ NSSortDescriptor(key: "text", ascending: true) ])
        }
        updateViewFromModel()
    }
    
    private func sortMenuSortAlphabeticallyDescendingButtonPressed() {
        if(displayMode == .incomes) {
            achievementsDataModel?.sortIncomeTemplates(by: [ NSSortDescriptor(key: "text", ascending: false) ])
        } else {
            achievementsDataModel?.sortExpenseTemplates(by: [ NSSortDescriptor(key: "text", ascending: false) ])
        }
        updateViewFromModel()
    }
    
    private func sortMenuSortByAmountButtonPressed() {
        if(displayMode == .incomes) {
            achievementsDataModel?.sortIncomeTemplates(by: [ NSSortDescriptor(key: "amount", ascending: true) ])
        } else {
            achievementsDataModel?.sortExpenseTemplates(by: [ NSSortDescriptor(key: "amount", ascending: false) ])
        }
        updateViewFromModel()
    }
    
    private func sortMenuSortByAmountDescendingButtonPressed() {
        if(displayMode == .incomes) {
            achievementsDataModel?.sortIncomeTemplates(by: [ NSSortDescriptor(key: "amount", ascending: false) ])
        } else {
            achievementsDataModel?.sortExpenseTemplates(by: [ NSSortDescriptor(key: "amount", ascending: true) ])
        }
        updateViewFromModel()
    }
    
    private func sortMenuSplitButtonPressed() {
        if (displayMode == .incomes) {
            Settings.applicationSettings.divideIncomeTemplatesByRecurrence = !Settings.applicationSettings.divideIncomeTemplatesByRecurrence
        } else {
            Settings.applicationSettings.divideExpenseTemplatesByRecurrence = !Settings.applicationSettings.divideExpenseTemplatesByRecurrence
        }
        setupSortMenu()
        updateViewFromModel()
    }
    
    private func swipeLeftEdit(at indexPath: IndexPath) {
        performSegue(withIdentifier: "EditTransactionTemplateSegue", sender: transactionTemplateFor(indexPath: indexPath))
    }
    
    private func swipeLeftDelete(at indexPath: IndexPath) {
        achievementsDataModel?.remove(transactionTemplate: transactionTemplateFor(indexPath: indexPath))
        refreshData()
        self.templatesTable.deleteRows(at: [indexPath], with: .automatic)
        updateEmptyScreenState()
    }
    
    private func swipeRightQuickBook(at indexPath: IndexPath) {
        let template = transactionTemplateFor(indexPath: indexPath)
        
        _ = self.achievementsDataModel?.createAchievementTransactionWith(
            text: template.text!,
            amount: template.amount,
            date: Date())
        
        if(!template.recurring) {
            achievementsDataModel?.remove(transactionTemplate: template)
            refreshData()
            
            self.templatesTable.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func transactionTemplateCellPressed(at indexPath: IndexPath) {
        AchievementTransactionsPresenter(achievevementsDataModel: achievementsDataModel!).bookAchievementTransaction(from: self, template: transactionTemplateFor(indexPath: indexPath))
    }
    
    // MARK: Setup Steps
    private func setupTemplatesTable() {
        self.templatesTable.dataSource = self
        self.templatesTable.delegate = self
        
        refreshData()
    }
    
    private func setupSortMenu() {
        let sortMenuItems = UIMenu(title: "sortMenu", options: .displayInline, children: [
            UIAction(
                title: NSLocalizedString("Amount Descending", comment: "Menu Item for sorting Transaction Templates by Amount (Descending)"),
                image: nil,
                handler: { _ in
                    self.sortMenuSortByAmountDescendingButtonPressed()
                }),
            UIAction(
                title: NSLocalizedString("Amount Ascending", comment: "Menu Item for sorting Transaction Templates by Amount (Ascending)"),
                image: nil,
                handler: { _ in
                    self.sortMenuSortByAmountButtonPressed()
                }),
            UIAction(
                title: "Z-A",
                image: nil,
                handler: { _ in
                    self.sortMenuSortAlphabeticallyDescendingButtonPressed()
                }),
            UIAction(
                title: "A-Z",
                image: nil,
                handler: { _ in
                    self.sortMenuSortAlphabeticallyButtonPressed()
                }),
        ])
        
        let splitMenuItems : UIMenu
        if(displayMode == .incomes) {
            splitMenuItems = UIMenu(title: "", options: .displayInline, children: [
                UIAction(
                    title: NSLocalizedString("Split Unique/Recurring", comment: "Menu Option to split into recurring and non recurring items"),
                    image: UIImage(systemName: Settings.applicationSettings.divideIncomeTemplatesByRecurrence ? "checkmark.square" : "square"),
                    handler: { _ in
                        self.sortMenuSplitButtonPressed()
                    }),
            ])
        } else {
            splitMenuItems = UIMenu(title: "", options: .displayInline, children: [
                UIAction(
                    title: NSLocalizedString("Split Unique/Recurring", comment: "Menu Option to split into recurring and non recurring items"),
                    image: UIImage(systemName: Settings.applicationSettings.divideExpenseTemplatesByRecurrence ? "checkmark.square" : "square"),
                    handler: { _ in
                        self.sortMenuSplitButtonPressed()
                    }),
            ])
        }
        
        sortButton.menu = UIMenu(title: "", children: [ splitMenuItems, sortMenuItems ])
    }
    
    // MARK: Private Functions
    private func updateViewFromModel() {
        refreshData()
        refreshSections()
        templatesTable.reloadData()
        
        updateEmptyScreenState()
    }
    
    private func transactionTemplateFor(indexPath: IndexPath) -> TransactionTemplate {
        let key = templatesTableSections[indexPath.section]
        let dictionaryEntry = templatesTableData[key]!
        
        return dictionaryEntry[indexPath.item]
    }
    
    private func refreshData() {
        // Determine what to display
        if(self.displayMode == .incomes) {
            // Determine, whether user wants recurring and unique to be split visually
            if(Settings.applicationSettings.divideIncomeTemplatesByRecurrence) {
                templatesTableData = [
                    NSLocalizedString("Recurring", comment: "Not Deleted after being booked once") : achievementsDataModel!.recurringIncomeTemplates,
                    NSLocalizedString("Unique", comment: "Deleted after being booked once") : achievementsDataModel!.nonRecurringIncomeTemplates,
                ]
            } else {
                templatesTableData =  [
                    "Templates" : achievementsDataModel!.incomeTemplates
                ]
            }
        } else {
            if(Settings.applicationSettings.divideExpenseTemplatesByRecurrence) {
                templatesTableData = [
                    NSLocalizedString("Recurring", comment: "Not Deleted after being booked once") : achievementsDataModel!.recurringExpenseTemplates,
                    NSLocalizedString("Unique", comment: "Deleted after being booked once") : achievementsDataModel!.nonRecurringExpenseTemplates,
                ]
            } else {
                templatesTableData =  [
                    "Templates" : achievementsDataModel!.expenseTemplates
                ]
            }
        }
    }
    
    private func refreshSections() {
        templatesTableSections = Array(templatesTableData.keys)
        templatesTableSections.sort(by: <)
    }
    
    private func updateEmptyScreenState() {
        var empty = true
        for section in self.templatesTableSections {
            if(!templatesTableData[section]!.isEmpty) {
                empty = false
            }
        }
        
        if(empty) {
            if(self.emptyScreenLabel != nil) { return }
            
            let label = UILabel()
            label.text = NSLocalizedString("There are no Templates yet.\n\nTemplates can be added with the + Button in the bottom left hand corner.", comment: "Empty Screen Text for Transaction Templates")
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
                    relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual,
                    toItem: nil,
                    attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                    multiplier: 1,
                    constant: 200)
            ])
            self.templatesTable.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: templatesTable.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: templatesTable.centerYAnchor).isActive = true
            
            self.emptyScreenLabel = label
        } else {
            if let label = self.emptyScreenLabel {
                label.removeFromSuperview()
                self.emptyScreenLabel = nil
            }
        }
    }
}

enum TransactionTemplatesListMode {
    case incomes, expenses
}
