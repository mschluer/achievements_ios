//
//  PlannedIncomesViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 04.09.21.
//

import UIKit

class PlannedIncomesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    
    // MARK: Variables
    private var recurringTransactionTemplates: [TransactionTemplate] = []
    private var nonRecurringTransactionTemplates: [TransactionTemplate] = []

    // MARK: Outlets
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var templatesTable: UITableView!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSortMenu()
        setupTemplateTable()
        
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
         return 2
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
                cell.detailTextLabel?.text = String (format: "%.2f", template.amount)
            } else if template.amount > 0 {
                cell.detailTextLabel?.textColor = UIColor.systemGreen
                cell.detailTextLabel?.text = String (format: "%.2f", template.amount)
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
        let item : TransactionTemplate
        
        // Remove from Source
        if sourceIndexPath.section == 0 {
            // Unique
            item = nonRecurringTransactionTemplates.remove(at: sourceIndexPath.item)
        } else {
            // Recurring
            item = recurringTransactionTemplates.remove(at: sourceIndexPath.item)
        }
        
        // Add to Destination and update model
        if destinationIndexPath.section == 0 {
            // Unique
            let destinationIndex : Int
            if destinationIndexPath.item >= nonRecurringTransactionTemplates.count {
                destinationIndex = nonRecurringTransactionTemplates.count - 1
            } else {
                destinationIndex = destinationIndexPath.item
            }
            
            let newIndex = nonRecurringTransactionTemplates[destinationIndex].orderIndex
            nonRecurringTransactionTemplates.insert(item, at: destinationIndexPath.item)
            achievementsDataModel?.rearrangeTransactionTemplates(template: item, destinationIndex: Int(newIndex))
        } else {
            // Recurring
            let destinationIndex : Int
            if destinationIndexPath.item >= recurringTransactionTemplates.count {
                destinationIndex = recurringTransactionTemplates.count - 1
            } else {
                destinationIndex = destinationIndexPath.item
            }
            
            let newIndex = recurringTransactionTemplates[destinationIndex].orderIndex
            recurringTransactionTemplates.insert(item, at: destinationIndexPath.item)
            achievementsDataModel?.rearrangeTransactionTemplates(template: item, destinationIndex: Int(newIndex))
        }
        
        // Make sure to update the recurring-flag if necessary
        if sourceIndexPath.section != destinationIndexPath.section {
            item.recurring = !item.recurring
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return nonRecurringTransactionTemplates.count
        } else {
            return recurringTransactionTemplates.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(self.templatesTable, numberOfRowsInSection: section) > 0 {
            switch(section) {
            case 1:
                return NSLocalizedString("Recurring", comment: "Not Deleted after being booked once")
            default:
                return NSLocalizedString("Unique", comment: "Deleted after being booked once")
            }
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
        achievementsDataModel?.sortPlannedIncomes(by: [ NSSortDescriptor(key: "text", ascending: true) ])
        updateViewFromModel()
    }
    
    private func sortMenuSortAlphabeticallyDescendingButtonPressed() {
        achievementsDataModel?.sortPlannedIncomes(by: [ NSSortDescriptor(key: "text", ascending: false) ])
        updateViewFromModel()
    }
    
    private func sortMenuSortByAmountButtonPressed() {
        achievementsDataModel?.sortPlannedIncomes(by: [ NSSortDescriptor(key: "amount", ascending: true) ])
        updateViewFromModel()
    }
    
    private func sortMenuSortByAmountDescendingButtonPressed() {
        achievementsDataModel?.sortPlannedIncomes(by: [ NSSortDescriptor(key: "amount", ascending: false) ])
        updateViewFromModel()
    }
    
    private func swipeLeftEdit(at indexPath: IndexPath) {
        performSegue(withIdentifier: "EditTransactionTemplateSegue", sender: transactionTemplateFor(indexPath: indexPath))
    }
    
    private func swipeLeftDelete(at indexPath: IndexPath) {
        achievementsDataModel?.remove(transactionTemplate: transactionTemplateFor(indexPath: indexPath))
        refreshDataFor(indexPath: indexPath)
        self.templatesTable.deleteRows(at: [indexPath], with: .automatic)
    }
    
    private func swipeRightQuickBook(at indexPath: IndexPath) {
        let template = transactionTemplateFor(indexPath: indexPath)
        
        _ = self.achievementsDataModel?.createAchievementTransactionWith(
            text: template.text!,
            amount: template.amount,
            date: Date())
        
        if(!template.recurring) {
            achievementsDataModel?.remove(transactionTemplate: template)
            refreshDataFor(indexPath: indexPath)
            
            self.templatesTable.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func transactionTemplateCellPressed(at indexPath: IndexPath) {
        AchievementTransactionsPresenter(achievevementsDataModel: achievementsDataModel!).bookAchievementTransaction(from: self, template: transactionTemplateFor(indexPath: indexPath))
    }
    
    // MARK: Setup Steps
    private func setupTemplateTable() {
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
        
        sortButton.menu = UIMenu(title: "", children: [ sortMenuItems ])
    }
    
    // MARK: Private Functions
    private func updateViewFromModel() {
        refreshData()
        templatesTable.reloadData()
    }
    
    private func transactionTemplateFor(indexPath: IndexPath) -> TransactionTemplate {
        if(indexPath.section == 0) {
            return nonRecurringTransactionTemplates[indexPath.item]
        } else {
            return recurringTransactionTemplates[indexPath.item]
        }
    }
    
    private func refreshDataFor(indexPath: IndexPath) {
        if(indexPath.section == 0) {
            nonRecurringTransactionTemplates = achievementsDataModel?.nonRecurringIncomeTemplates ?? []
        } else {
            recurringTransactionTemplates = achievementsDataModel?.recurringIncomeTemplates ?? []
        }
    }
    
    private func refreshData() {
        nonRecurringTransactionTemplates = achievementsDataModel?.nonRecurringIncomeTemplates ?? []
        recurringTransactionTemplates = achievementsDataModel?.recurringIncomeTemplates ?? []
    }
}
