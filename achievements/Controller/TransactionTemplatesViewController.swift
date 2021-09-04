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
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTransactionTemplateFormSegue" {
            let destination = segue.destination as! TransactionTemplateFormController
            
            destination.achievementsDataModel = achievementsDataModel
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
            } else {
                cell.detailTextLabel?.textColor = UIColor.systemGreen
                cell.detailTextLabel?.text = String (format: "%.2f", transactionTemplates[indexPath.item].amount)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: Action Handlers
    
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
