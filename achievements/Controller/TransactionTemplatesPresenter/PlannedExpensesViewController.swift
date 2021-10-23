//
//  PlannedExpensesViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 08.10.21.
//

import UIKit

class PlannedExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    // MARK: Persistence Models
    public var achievementsDataModel : AchievementsDataModel?
    
    // MARK: Variables
    private var plannedExpenses: [TransactionTemplate] = []

    // MARK: Outlets
    @IBOutlet weak var plannedExpensesTable: UITableView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSortMenu()
        setupPlannedExpensesTable()
        
        plannedExpensesTable.dragInteractionEnabled = true
        plannedExpensesTable.dragDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViewFromModel()
    }

    // MARK: Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell") {
            let template = plannedExpenseFor(indexPath: indexPath)
            
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
        plannedExpenseCellPressed(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = plannedExpenseFor(indexPath: indexPath)
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard plannedExpenseFor(indexPath: indexPath).isQuickBookable() else {
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
        // Update Table View Data
        let item = plannedExpenses.remove(at: sourceIndexPath.item)
        plannedExpenses.insert(item, at: destinationIndexPath.item)
        
        // Update Data
        achievementsDataModel?.rearrangeTransactionTemplates(template: item, destinationIndex: destinationIndexPath.item)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plannedExpenses.count
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
    private func swipeLeftEdit(at indexPath: IndexPath) {
        performSegue(withIdentifier: "EditExpenseTemplateSegue", sender: plannedExpenseFor(indexPath: indexPath))
    }
    
    private func swipeLeftDelete(at indexPath: IndexPath) {
        achievementsDataModel?.remove(transactionTemplate: plannedExpenseFor(indexPath: indexPath))
        refreshDataFor(indexPath: indexPath)
        self.plannedExpensesTable.deleteRows(at: [indexPath], with: .automatic)
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "AddPlannedExpenseSegue":
            let destination = segue.destination as! TransactionTemplateFormController
            destination.flipSignOnShow = true
            destination.achievementsDataModel = achievementsDataModel
        case "EditExpenseTemplateSegue":
            let destination = segue.destination as! TransactionTemplateFormController
            destination.achievementsDataModel = achievementsDataModel
            destination.transactionTemplate = (sender as! TransactionTemplate)
        default:
            break
        }
    }
    
    // MARK: Action Handlers
    private func plannedExpenseCellPressed(at indexPath: IndexPath) {
        AchievementTransactionsPresenter(achievevementsDataModel: achievementsDataModel!).bookAchievementTransaction(from: self, template: plannedExpenseFor(indexPath: indexPath))
    }
    
    private func sortMenuSortAlphabeticallyButtonPressed() {
        achievementsDataModel?.sortPlannedExpenses(by: [ NSSortDescriptor(key: "text", ascending: true) ])
        updateViewFromModel()
    }
    
    private func sortMenuSortAlphabeticallyDescendingButtonPressed() {
        achievementsDataModel?.sortPlannedExpenses(by: [ NSSortDescriptor(key: "text", ascending: false) ])
        updateViewFromModel()
    }
    
    private func sortMenuSortByAmountButtonPressed() {
        achievementsDataModel?.sortPlannedExpenses(by: [ NSSortDescriptor(key: "amount", ascending: false) ])
        updateViewFromModel()
    }
    
    private func sortMenuSortByAmountDescendingButtonPressed() {
        achievementsDataModel?.sortPlannedExpenses(by: [ NSSortDescriptor(key: "amount", ascending: true) ])
        updateViewFromModel()
    }
    
    private func swipeRightQuickBook(at indexPath: IndexPath) {
        let template = plannedExpenseFor(indexPath: indexPath)
        
        _ = self.achievementsDataModel?.createAchievementTransactionWith(
            text: template.text!,
            amount: template.amount,
            date: Date())
        
        if(!template.recurring) {
            achievementsDataModel?.remove(transactionTemplate: template)
            refreshDataFor(indexPath: indexPath)
            
            self.plannedExpensesTable.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: Setup Steps
    private func setupPlannedExpensesTable() {
        self.plannedExpensesTable.dataSource = self
        self.plannedExpensesTable.delegate = self
        
        updateViewFromModel()
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
    
    // MARK: Private functions
    private func plannedExpenseFor(indexPath : IndexPath) -> TransactionTemplate {
        return plannedExpenses[indexPath.item]
    }
    
    private func refreshData() {
        plannedExpenses = achievementsDataModel?.plannedExpenses ?? []
    }
    
    private func refreshDataFor(indexPath: IndexPath) {
        refreshData()
    }
    
    private func updateViewFromModel() {
        refreshData()
        plannedExpensesTable.reloadData()
    }
}
