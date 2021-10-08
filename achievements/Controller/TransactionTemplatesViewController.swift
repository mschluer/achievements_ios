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
    
    // MARK: Variables
    private var nonRecurringTransactionTemplates: [TransactionTemplate] = []
    private var recurringTransactionTemplates: [TransactionTemplate] = []

    // MARK: Outlets
    @IBOutlet weak var templatesTable: UITableView!
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTemplateTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewFromModel()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTransactionTemplateFormSegue" {
            let destination = segue.destination as! TransactionTemplateFormController
            
            destination.achievementsDataModel = achievementsDataModel
        } else if segue.identifier == "BookTransactionTemplateSegue" {
            let destination = segue.destination as! TransactionFormController
            
            destination.transactionTemplate = (sender as! TransactionTemplate)
            destination.achievementTransactionModel = self.achievementsDataModel
        } else if segue.identifier == "EditTransactionTemplateSegue" {
            let destination = segue.destination as! TransactionTemplateFormController
            
            destination.achievementsDataModel = achievementsDataModel
            destination.transactionTemplate = (sender as! TransactionTemplate)
        }
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
         return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return "Einmalig"
        } else {
            return "Wiederkehrend"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return nonRecurringTransactionTemplates.count
        } else {
            return recurringTransactionTemplates.count
        }
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let book = UIContextualAction(style: .normal, title: "Buchen") { (action, view, completion) in
            self.swipeRightQuickBook(at: indexPath)
            completion(false)
        }
        book.backgroundColor = .systemGreen
        
        let config = UISwipeActionsConfiguration(actions: [book])
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Bearbeiten") { (action, view, completion) in
            self.swipeLeftEdit(at: indexPath)
            completion(false)
        }
        edit.backgroundColor = .systemYellow
        
        let delete = UIContextualAction(style: .destructive, title: "Löschen") { (action, view, completion) in
            self.swipeLeftDelete(at: indexPath)
            completion(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return config
    }
    
    // MARK: Action Handlers
    private func swipeRightQuickBook(at indexPath: IndexPath) {
        let template = transactionTemplateFor(indexPath: indexPath)
        
        if template.text == "" || template.amount == 0 {
            let insufficientDataAlert = UIAlertController(title: "Unzureichende Daten", message: "Um diese Vorlage schnell zu buchen, müssen die Daten vollständig sein.", preferredStyle: .alert)
            insufficientDataAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(insufficientDataAlert, animated: true)
        } else {
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
    }
    
    private func transactionTemplateCellPressed(at indexPath: IndexPath) {
        performSegue(withIdentifier: "BookTransactionTemplateSegue", sender: transactionTemplateFor(indexPath: indexPath))
    }
    
    private func swipeLeftEdit(at indexPath: IndexPath) {
        performSegue(withIdentifier: "EditTransactionTemplateSegue", sender: transactionTemplateFor(indexPath: indexPath))
    }
    
    private func swipeLeftDelete(at indexPath: IndexPath) {
        achievementsDataModel?.remove(transactionTemplate: transactionTemplateFor(indexPath: indexPath))
        refreshDataFor(indexPath: indexPath)
        self.templatesTable.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Setup Steps
    private func setupTemplateTable() {
        self.templatesTable.dataSource = self
        self.templatesTable.delegate = self
        
        refreshData()
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
