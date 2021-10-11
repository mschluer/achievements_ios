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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plannedExpenses.count
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard plannedExpenseFor(indexPath: indexPath).isQuickBookable() else {
            return nil
        }
        let book = UIContextualAction(style: .normal, title: "Book") { (action, view, completion) in
            self.swipeRightQuickBook(at: indexPath)
            completion(false)
        }
        book.backgroundColor = .systemGreen
        
        let config = UISwipeActionsConfiguration(actions: [book])
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.swipeLeftEdit(at: indexPath)
            completion(false)
        }
        edit.backgroundColor = .systemYellow
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.swipeLeftDelete(at: indexPath)
            completion(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return config
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update Table View Data
        let item = plannedExpenses.remove(at: sourceIndexPath.item)
        plannedExpenses.insert(item, at: destinationIndexPath.item)
        
        // Update Data
        achievementsDataModel?.rearrangeTransactionTemplates(template: item, destinationIndex: destinationIndexPath.item)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = plannedExpenseFor(indexPath: indexPath)
        return [ dragItem ]
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
        case "BookExpenseTemplateSegue":
            let destination = segue.destination as! AchievementTransactionFormController
            destination.transactionTemplate = (sender as! TransactionTemplate)
            destination.achievementsDataModel = self.achievementsDataModel
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
        performSegue(withIdentifier: "BookExpenseTemplateSegue", sender: plannedExpenseFor(indexPath: indexPath))
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
    
    // MARK: Private functions
    private func updateViewFromModel() {
        refreshData()
        plannedExpensesTable.reloadData()
    }
    
    private func refreshData() {
        plannedExpenses = achievementsDataModel?.plannedExpenses ?? []
    }
    
    private func refreshDataFor(indexPath: IndexPath) {
        // To be extended once there are sections
        refreshData()
    }
    
    private func plannedExpenseFor(indexPath : IndexPath) -> TransactionTemplate {
        return plannedExpenses[indexPath.item]
    }
}
