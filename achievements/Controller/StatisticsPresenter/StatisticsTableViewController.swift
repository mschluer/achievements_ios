//
//  StatisticsTableViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 26.10.21.
//

import UIKit
import Charts

class StatisticsTableViewController: UITableViewController {
    // MARK: Persistence Model
    public var achievementsDataModel : AchievementsDataModel?

    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
            case 0: return NSLocalizedString("Recent", comment: "Statistics Headline for Recent Transactions.")
            case 1: return NSLocalizedString("Total", comment: "Statistics Headline for Historical Transactions.")
            case 2: return NSLocalizedString("Balance History", comment: "Headline for the Balance History Line Chart in Statistics View ")
            default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = achievementsDataModel else {
            return UITableViewCell()
        }
        
        let cell : UITableViewCell

        switch(indexPath.section) {
        case 0:
            // Recent
            let c = tableView.dequeueReusableCell(withIdentifier: "statisticsTableViewDataCell", for: indexPath) as! StatisticsTableViewDataCell
            
            if(indexPath.item == 0) {
                c.lhsLabel.text = NumberHelper.formattedString(for: model.totalRecentIncomes)
                c.lhsLabel.textColor = .green
                
                c.rhsLabel.text = NumberHelper.formattedString(for: model.totalRecentExpenses)
                c.rhsLabel.textColor = .red
            } else {
                c.lhsLabel.text = "\(NumberHelper.formattedString(for: model.recentIncomes.count))"
                c.rhsLabel.text = "\(NumberHelper.formattedString(for: model.recentExpenses.count))"
            }
            
            cell = c
        case 1:
            // Total
            let c = tableView.dequeueReusableCell(withIdentifier: "statisticsTableViewDataCell", for: indexPath) as! StatisticsTableViewDataCell
            
            if(indexPath.item == 0) {
                c.lhsLabel.text = NumberHelper.formattedString(for: model.totalHistoricalIncomes)
                c.lhsLabel.textColor = .green
                
                c.rhsLabel.text = NumberHelper.formattedString(for: model.totalHistoricalExpenses)
                c.rhsLabel.textColor = .red
            } else {
                c.lhsLabel.text = "\(NumberHelper.formattedString(for: model.historicalIncomes.count))"
                c.rhsLabel.text = "\(NumberHelper.formattedString(for: model.historicalExpenses.count))"
            }
            
            cell = c
        default:
            // Balance Chart
            let c = tableView.dequeueReusableCell(withIdentifier: "statisticsTableViewChartCell", for: indexPath) as! StatisticsTableViewChartCell
            
            prepare(c.lineChartView, with: model)
            
            cell = c
        }

        cell.isUserInteractionEnabled = false
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath == IndexPath(item: 0, section: 2)) {
            return 220.0
        } else{
            return UITableView.automaticDimension
        }
    }
    
    // MARK: Private Functions
    private func prepare(_ chartView: LineChartView, with model: AchievementsDataModel) {
        var chartEntries = [ChartDataEntry]()
        for i in 0..<model.historicalTransactions.count {
            chartEntries.append(ChartDataEntry(x: Double(i), y: Double(model.historicalTransactionsReverse[i].balance)))
        }
        let balanceLine = LineChartDataSet(entries: chartEntries)
        balanceLine.colors = [NSUIColor.blue]
        balanceLine.drawCirclesEnabled = false
        balanceLine.drawValuesEnabled = false
        
        var zeroLineEntries = [ChartDataEntry]()
        for i in 0..<model.historicalTransactions.count {
            zeroLineEntries.append(ChartDataEntry(x: Double(i), y: 0.0))
        }
        let zeroLine = LineChartDataSet(entries: zeroLineEntries)
        zeroLine.colors = [UIColor.systemGray]
        zeroLine.drawCirclesEnabled = false
        zeroLine.drawValuesEnabled = false
        
        let data = LineChartData()
        data.addDataSet(balanceLine)
        data.addDataSet(zeroLine)
        
    chartView.data = data
            
        chartView.rightAxis.enabled = false
        chartView.drawGridBackgroundEnabled = false
            
        chartView.leftAxis.enabled = false
        chartView.xAxis.enabled = false
        chartView.legend.enabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
    }
}

class StatisticsTableViewChartCell : UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var lineChartView: LineChartView!
}

class StatisticsTableViewDataCell : UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var lhsLabel: UILabel!
    @IBOutlet weak var rhsLabel: UILabel!
}

