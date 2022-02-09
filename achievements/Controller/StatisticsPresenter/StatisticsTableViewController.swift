//
//  StatisticsTableViewController.swift
//  achievements
//
//  Created by Maximilian Schluer on 26.10.21.
//

import UIKit
import Charts

class StatisticsTableViewController: UITableViewController {
    // MARK: Public Variables
    public var totalRecentIncomes : Float = 0.0
    public var totalRecentExpenses : Float = 0.0
    public var amountRecentIncomes : Int = 0
    public var amountRecentExpenses : Int = 0
    
    public var totalIncomes : Float = 0.0
    public var totalExpenses : Float = 0.0
    public var amountIncomes : Int = 0
    public var amountExpenses : Int = 0
    
    public var endOfDayBalances : [Date : Float] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [ IndexPath(item: 0, section: 2) ], with: .automatic)
            }
        }
    }
    public var endOfDayBalanceDeltas : [Date : Float] = [:] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [ IndexPath(item: 0, section: 3) ], with: .automatic)
            }
        }
    }
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
            case 0: return NSLocalizedString("Recent", comment: "Statistics Headline for Recent Transactions.")
            case 1: return NSLocalizedString("Total", comment: "Statistics Headline for Historical Transactions.")
            case 2: return NSLocalizedString("Balance History", comment: "Headline for the Balance History Line Chart in Statistics View.")
            case 3: return NSLocalizedString("Day Delta", comment: "Headline for the Day Delta Chart.")
            default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0: return 2
            case 1: return 2
            case 2: return 1
            default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell

        switch(indexPath.section) {
        case 0:
            // Recent
            let c = tableView.dequeueReusableCell(withIdentifier: "statisticsTableViewDataCell", for: indexPath) as! StatisticsTableViewDataCell
            
            if(indexPath.item == 0) {
                c.lhsLabel.text = NumberHelper.formattedString(for: totalRecentIncomes)
                c.lhsLabel.textColor = .green
                
                c.rhsLabel.text = NumberHelper.formattedString(for: totalRecentExpenses)
                c.rhsLabel.textColor = .red
            } else {
                c.lhsLabel.text = "\(NumberHelper.formattedString(for: amountRecentIncomes))"
                c.rhsLabel.text = "\(NumberHelper.formattedString(for: amountRecentExpenses))"
            }
            
            cell = c
        case 1:
            // Total
            let c = tableView.dequeueReusableCell(withIdentifier: "statisticsTableViewDataCell", for: indexPath) as! StatisticsTableViewDataCell
            
            if(indexPath.item == 0) {
                c.lhsLabel.text = NumberHelper.formattedString(for: totalIncomes)
                c.lhsLabel.textColor = .green
                
                c.rhsLabel.text = NumberHelper.formattedString(for: totalExpenses)
                c.rhsLabel.textColor = .red
            } else {
                c.lhsLabel.text = "\(NumberHelper.formattedString(for: amountIncomes))"
                c.rhsLabel.text = "\(NumberHelper.formattedString(for: amountExpenses))"
            }
            
            cell = c
        case 2:
            // Balance Chart
            let c = tableView.dequeueReusableCell(withIdentifier: "statisticsTableViewChartCell", for: indexPath) as! StatisticsTableViewChartCell
            
            if(endOfDayBalances.isEmpty) {
                SpinnerViewController().showOn(c.contentView)
            } else {
                self.refresh(balanceLineChartView: c.lineChartView)
            }
            
            cell = c
        default:
            // Day Delta Bar Chart
            let c = tableView.dequeueReusableCell(withIdentifier: "statisticsTableViewBarChartCell", for: indexPath) as! StatisticsTableViewBarChartCell
            
            if(endOfDayBalanceDeltas.isEmpty) {
                SpinnerViewController().showOn(c.contentView)
            } else {
                self.refresh(dayDeltaBarChartView: c.barChartView)
            }
            
            cell = c
        }

        cell.isUserInteractionEnabled = false
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(item: 0, section: 2) {
            // Balance History Line Chart
            return 220.0
        } else if indexPath == IndexPath(item: 0, section: 3) {
            // Day Delta Bar Chart
            return 220.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    // MARK: Private Functions
    private func refresh(balanceLineChartView: LineChartView) {
        if endOfDayBalances.isEmpty { return }
        
        var chartEntries = [ChartDataEntry]()
        let maximumEntries, offset : Int
        
        let totalChartItems = endOfDayBalances.count
        if  totalChartItems > Settings.statisticsSettings.lineChartMaxAmountRecords {
            maximumEntries = Settings.statisticsSettings.lineChartMaxAmountRecords
            offset = totalChartItems - maximumEntries
        } else {
            maximumEntries = totalChartItems
            offset = 0
        }
        
        var keys = Array(endOfDayBalances.keys)
        keys.sort(by: <)
        
        for i in 0..<maximumEntries {
            let key = keys[i + offset]
            chartEntries.append(ChartDataEntry(x: Double(i), y: Double(endOfDayBalances[key]!)))
        }
        let balanceLine = LineChartDataSet(entries: chartEntries)
        balanceLine.colors = [NSUIColor.blue]
        balanceLine.drawCirclesEnabled = false
        balanceLine.drawValuesEnabled = false
        
        var zeroLineEntries = [ChartDataEntry]()
        for i in 0...maximumEntries {
            zeroLineEntries.append(ChartDataEntry(x: Double(i), y: 0.0))
        }
        let zeroLine = LineChartDataSet(entries: zeroLineEntries)
        zeroLine.colors = [UIColor.systemGray]
        zeroLine.drawCirclesEnabled = false
        zeroLine.drawValuesEnabled = false
        
        let data = LineChartData()
        data.addDataSet(balanceLine)
        data.addDataSet(zeroLine)
        
        balanceLineChartView.data = data
            
        balanceLineChartView.rightAxis.enabled = false
        balanceLineChartView.drawGridBackgroundEnabled = false
            
        balanceLineChartView.leftAxis.enabled = false
        balanceLineChartView.xAxis.enabled = false
        balanceLineChartView.legend.enabled = false
        balanceLineChartView.doubleTapToZoomEnabled = false
        balanceLineChartView.highlightPerTapEnabled = false
        balanceLineChartView.highlightPerDragEnabled = false
    }
    
    private func refresh(dayDeltaBarChartView: BarChartView) {
        if endOfDayBalanceDeltas.isEmpty { return }
        
        var positiveChartEntries = [ChartDataEntry]()
        var negativeChartEntries = [ChartDataEntry]()
        let maximumEntries, offset : Int
        let totalChartItems = endOfDayBalanceDeltas.count
        
        // Calculate the offset
        if  totalChartItems > Settings.statisticsSettings.dayDeltaChartMaxAmountEntries {
            maximumEntries = Settings.statisticsSettings.dayDeltaChartMaxAmountEntries
            offset = totalChartItems - maximumEntries
        } else {
            maximumEntries = totalChartItems
            offset = 0
        }
        
        // Prepare Keys
        var keys = Array(endOfDayBalanceDeltas.keys)
        keys.sort(by: <)
        
        // Compile With Values
        for i in 0..<maximumEntries {
            let key = keys[i + offset]
            let value = Double(endOfDayBalanceDeltas[key]!)
            
            if value >= 0 {
                positiveChartEntries.append(BarChartDataEntry(x: Double(i), y: value))
            } else {
                negativeChartEntries.append(BarChartDataEntry(x: Double(i), y: value))
            }
        }
        
        let positiveDataset = BarChartDataSet(entries: positiveChartEntries)
        positiveDataset.colors = [ UIColor.green ]
        let negativeDataset = BarChartDataSet(entries: negativeChartEntries)
        negativeDataset.colors = [ UIColor.red ]
        let data = BarChartData(dataSets: [ positiveDataset, negativeDataset ])
        
        // Hide or Show
        if Settings.statisticsSettings.dayDeltaChartMaxAmountEntries > 10 {
            positiveDataset.drawValuesEnabled = false
            negativeDataset.drawValuesEnabled = false
        } else {
            positiveDataset.valueFont = UIFont.systemFont(ofSize: 15.0)
            negativeDataset.valueFont = UIFont.systemFont(ofSize: 15.0)
        }
        
        dayDeltaBarChartView.data = data
        
        dayDeltaBarChartView.leftAxis.enabled = false
        dayDeltaBarChartView.rightAxis.enabled = false
        dayDeltaBarChartView.drawGridBackgroundEnabled = false
        dayDeltaBarChartView.xAxis.enabled = false
        dayDeltaBarChartView.legend.enabled = false
        dayDeltaBarChartView.doubleTapToZoomEnabled = false
        dayDeltaBarChartView.highlightPerDragEnabled = false
    }
}

class StatisticsTableViewBarChartCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var barChartView: BarChartView!
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
