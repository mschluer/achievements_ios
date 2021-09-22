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
    private var transactionTemplates: [TransactionTemplate] = []

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell") {
            cell.textLabel?.text = transactionTemplates[indexPath.item].text
            if transactionTemplates[indexPath.item].amount < 0 {
                cell.detailTextLabel?.textColor = UIColor.systemRed
                cell.detailTextLabel?.text = String (format: "%.2f", transactionTemplates[indexPath.item].amount)
            } else if transactionTemplates[indexPath.item].amount > 0 {
                cell.detailTextLabel?.textColor = UIColor.systemGreen
                cell.detailTextLabel?.text = String (format: "%.2f", transactionTemplates[indexPath.item].amount)
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
            self.swipeRightQuickBook(transactionTemplate: self.transactionTemplates[indexPath.item])
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
    private func swipeRightQuickBook(transactionTemplate template: TransactionTemplate) {
        if template.text == "" || template.amount == 0 {
            let insufficientDataAlert = UIAlertController(title: "Unzureichende Daten", message: "Um diese Vorlage schnell zu buchen, müssen die Daten vollständig sein.", preferredStyle: .alert)
            insufficientDataAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(insufficientDataAlert, animated: true)
        } else {
            _ = self.achievementsDataModel?.createAchievementTransactionWith(
                text: template.text!,
                amount: template.amount,
                date: Date())
        }
    }
    
    private func transactionTemplateCellPressed(at indexPath: IndexPath) {
        performSegue(withIdentifier: "BookTransactionTemplateSegue", sender: transactionTemplates[indexPath.item])
    }
    
    private func swipeLeftEdit(at indexPath: IndexPath) {
        performSegue(withIdentifier: "EditTransactionTemplateSegue", sender: transactionTemplates[indexPath.item])
    }
    
    private func swipeLeftDelete(at indexPath: IndexPath) {
        achievementsDataModel?.remove(transactionTemplate: transactionTemplates[indexPath.item])
        transactionTemplates = achievementsDataModel?.transactionTemplates ?? []
        
        self.templatesTable.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Setup Steps
    private func setupTemplateTable() {
        self.templatesTable.dataSource = self
        self.templatesTable.delegate = self
        
        transactionTemplates = achievementsDataModel?.transactionTemplates ?? []
    }
    
    // MARK: Private Functions
    private func updateViewFromModel() {
        transactionTemplates = self.achievementsDataModel?.transactionTemplates ?? []
        templatesTable.reloadData()
    }
}
