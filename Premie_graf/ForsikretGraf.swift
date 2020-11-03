//
//  ViewController.swift
//  Premie_graf
//
//  Created by Bjørn Reitzer on 26/10/2020.
//  Copyright © 2020 Bjørn Reitzer. All rights reserved.
//

import UIKit
import Highcharts

// This is the class for the graph of the initial purchase of an insurance

class ForsikretGraf: UIViewController {
    var chartView: HIChartView!, chartView2: HIChartView!
    
    // Premium history from insurance object
    // (https://www.tillit.eu/api/v1/insuranceobjects/iPhone%20XS%20Max/)
    struct Premium {
        var id: Int
        var premium_base: Int
        var created: String
    }
    
    let premium_set: [Premium]  = [
        Premium(id: 85, premium_base: 1800, created: "2020-10-29T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 1500, created: "2020-09-28T12:28:09.793201Z"),
        Premium(id: 85, premium_base: 1900, created: "2020-08-20T12:28:09.793201Z"),
    ]
    
    struct UserInsurance {
        var price: Int
        var has_dynamic_price: Bool
    }
    
    struct Charge {
        var id: Int
        var amount: Int
        var description: String
        var due_date: String
        var status: String
        var amount_refunded: Int
        var transaction_id: String
    }
    
    // Static: If 12-1 charges with same prices -> Be ready for update
    // https://www.tillit.eu/api/v1/insurances/677/
    let insurance = UserInsurance(price: 1300, has_dynamic_price: false)
    let charges = [
        Charge(id: 425, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-12-03T00:00:00Z", status: "WAITING", amount_refunded: 0, transaction_id: ""),
        Charge(id: 424, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-11-02T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 423, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-10-03T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 422, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-09-03T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 421, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-08-04T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 420, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-07-04T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 419, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-06-05T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 418, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-09-06T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 417, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-05-08T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 416, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-04-08T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 415, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-03-09T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        Charge(id: 414, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-02-09T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
//        Charge(id: 413, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-01-10T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
//        Charge(id: 412, amount: 1300, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2019-12-10T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        
        
        //                Charge(id: 421, amount: 1800, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-08-08T07:30:31Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        //        Charge(id: 420, amount: 1200, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-07-08T00:00:00Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        //        Charge(id: 419, amount: 1700, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-06-09T00:00:00Z", status: "CHARGED", amount_refunded: 0, transaction_id: ""),
        //        Charge(id: 418, amount: 1900, description: "Skjerm-forsikring for iPhone XS Max", due_date: "2020-05-09T00:00:00Z", status: "CHARGED", amount_refunded: 0, transaction_id: "")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Date of period start
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        // Current Period start date
        var currentPremium: Int? = nil, currentPremiumDate = 0.00, previousPremium: Int? = nil, previousPremiumDate = 0.00, nextPremium = 0, nextPremiumDate = 0.00, premiumEstimateHigh = 0, premiumEstimateLow = 0, premiumEstimateDate = 0.00, chargedCount = 0, chargedToday = false
        
        for (index, charge) in charges.enumerated() {
            
            if(index == 0 && charge.status == "CHARGED"){
                // Next premium has not been set yet
                chargedToday = true;
                currentPremiumDate = (formatter2.date(from: charge.due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
                //                previousPremiumDate = (formatter2.date(from: charge.due_date))!.timeIntervalSince1970*1000 - (30 * 24 * 60 * 60 * 1000)
                
                nextPremium = charge.amount / 100
                nextPremiumDate = currentPremiumDate
                
                premiumEstimateHigh = Int((Double(nextPremium) * 1.20).rounded(.awayFromZero))
                premiumEstimateLow = Int((Double(nextPremium) * 0.80).rounded(.towardZero))
                premiumEstimateDate = nextPremiumDate + (30 * 24 * 60 * 60 * 1000) + (2 * 60 * 60 * 1000)
                
            } else if(index == 0 && charge.status == "WAITING"){
                // Next premium has been set
                
                nextPremium = charge.amount / 100
                nextPremiumDate = (formatter2.date(from: charge.due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
                
                premiumEstimateHigh = Int((Double(nextPremium) * 1.20).rounded(.awayFromZero))
                premiumEstimateLow = Int((Double(nextPremium) * 0.80).rounded(.towardZero))
                premiumEstimateDate = nextPremiumDate + (30 * 24 * 60 * 60 * 1000) + (2 * 60 * 60 * 1000)
                
            } else if (index == 1  && charge.status == "CHARGED"){
                currentPremium = charge.amount / 100
                currentPremiumDate = (formatter2.date(from: charge.due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            } else if (index == 2  && charge.status == "CHARGED"){
                previousPremium = charge.amount / 100
                previousPremiumDate = (formatter2.date(from: charge.due_date))!.timeIntervalSince1970*1000 + (2 * 60 * 60 * 1000)
            }
            if(charge.status == "CHARGED"){
                chargedCount+=1
            }
        }
        
        let today = Date().timeIntervalSince1970*1000
        
        self.chartView = HIChartView(frame:  CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400))
        self.chartView2 = HIChartView(frame:  CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400))
        
        self.chartView.alpha = 1
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.borderWidth = 1
        chart.borderColor = HIColor(hexValue: "ECECEC")
        chart.backgroundColor = HIColor(hexValue: "F8F8F8")
        options.chart = chart
        
        let title = HITitle()
        title.text = ""
        options.title = title
        
        let exporting = HIExporting()
        exporting.enabled = false
        options.exporting = exporting
        
        let credits = HICredits()
        credits.enabled = false
        options.credits = credits
        
        let legend = HILegend()
        legend.enabled = false
        options.legend = legend
        
        let nextPremiumDateBeforeBefore = nextPremiumDate - (60 * 24 * 60 * 60 * 1000)
        let nextPremiumDateBefore = nextPremiumDate - (30 * 24 * 60 * 60 * 1000)
        let premiumEstimateDateNext = premiumEstimateDate + (30 * 24 * 60 * 60 * 1000)
        
        // Initial purchase
        
        // Dynamic range
        let dynamic_range = HIArearange()
        dynamic_range.name = "dynamic_range"
        dynamic_range.lineWidth = 0
        print("No of charges: ", (12) % 12)
        if(insurance.has_dynamic_price || (((charges.count) % 12 == 0) || (chargedCount + 1) % 12 == 0)){
            dynamic_range.data = [
                [nextPremiumDateBefore, nextPremium, nextPremium], // This period (10/28/2020)
                [premiumEstimateDate, premiumEstimateLow, premiumEstimateHigh], // Next 30 days (11/27/2020)
                [premiumEstimateDateNext, premiumEstimateLow, premiumEstimateHigh] // Next 60 days (12/27/2020)
            ]
        }
        dynamic_range.dataLabels = HIDataLabels()
        dynamic_range.dataLabels.xHigh = 20
        dynamic_range.dataLabels.xLow = 20
        dynamic_range.dataLabels.yHigh = 45
        dynamic_range.dataLabels.yLow = -45
        
        dynamic_range.color = HIColor(linearGradient: ["x1": 0, "y1": 0, "x2": 1, "y2": 0], stops: [[0, "#82FFA0"], [1, "#3FFFFF"]])
        dynamic_range.fillColor = HIColor(linearGradient: ["x1": 0, "y1": 0, "x2": 1, "y2": 0], stops: [[0, "#82FFA0"], [1, "#3FFFFF"]])
        
        
        // Dynamic line
        let dynamic_line = HILine()
        if(chargedToday){
            dynamic_line.name = "dynamic_line_charged"
        } else {
            dynamic_line.name = "dynamic_line"
        }
        dynamic_line.lineWidth = 4
        if(insurance.has_dynamic_price || (((charges.count) % 12 == 0) || (chargedCount + 1) % 12 == 0)){
            dynamic_line.data = [
                [nextPremiumDateBeforeBefore, previousPremium as Any], // 60 days ago (08/29/2020)
                [nextPremiumDateBefore, currentPremium as Any], // 30 days ago (09/28/2020)
                [nextPremiumDate, nextPremium], // This period (10/28/2020)
                [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
            ]
        } else {
            dynamic_line.data = [
                [nextPremiumDateBeforeBefore, previousPremium as Any], // 60 days ago (08/29/2020)
                [nextPremiumDateBefore, currentPremium as Any], // 30 days ago (09/28/2020)
                [nextPremiumDate, nextPremium], // This period (10/28/2020)
                [premiumEstimateDate, nextPremium], // Next 30 days (11/27/2020)
                [premiumEstimateDateNext, nextPremium], // Next 60 days (11/27/2020)
            ]
        }
        
        dynamic_line.color = HIColor(hexValue: "82FFA0")
        
        let yAxis = HIYAxis()
        
        yAxis.title = HITitle()
        yAxis.title.text = ""
        
        yAxis.visible = false
        options.yAxis = [yAxis]
        
        let xAxis = HIXAxis()
        xAxis.gridLineWidth = 1
        xAxis.title = HITitle()
        xAxis.title.text = ""
        xAxis.type = "datetime"
        xAxis.lineColor = HIColor(hexValue: "ECECEC")
        xAxis.tickColor = HIColor(hexValue: "ECECEC")
        
        xAxis.labels = HILabels()
        xAxis.labels.align = "left"
        xAxis.labels.x = 5
        xAxis.labels.formatter = HIFunction(jsFunction:"function () {return Highcharts.dateFormat('%d.%m.%Y', this.value);}")
        
        print("60 days ago: \(nextPremiumDateBeforeBefore) \n30 days ago: \(nextPremiumDateBefore) \nCurrent: \(nextPremiumDate) \nNext low: \(premiumEstimateDate) \nNext high: \(premiumEstimateDateNext) ")
        
        xAxis.tickPositions = [
            NSNumber(value: previousPremiumDate), // 60 days ago (08/29/2020)
            NSNumber(value: currentPremiumDate), // 30 days ago (09/28/2020)
            NSNumber(value: nextPremiumDate), // This period (10/28/2020)
            NSNumber(value: premiumEstimateDate), // Next 30 days (11/27/2020)
            NSNumber(value: premiumEstimateDateNext), // Next 0 days (11/27/2020)
        ]
        
        let plotLine = HIPlotLines()
        plotLine.color = HIColor(hexValue: "000000")
        plotLine.width = 1
        plotLine.value = NSNumber(value: today)
        plotLine.label = HILabel()
        plotLine.label.text = "I dag"
        plotLine.label.rotation = 0
        plotLine.label.align = "center"
        plotLine.label.x = 0
        plotLine.label.style = HIStyle()
        plotLine.label.useHTML = true
        plotLine.label.style.backgroundColor = "#F8F8F8"
        
        plotLine.dashStyle = "dotted"
        plotLine.zIndex = 9
        xAxis.plotLines = [plotLine]
        
        xAxis.visible = true
        options.xAxis = [xAxis]
        
        let tooltip = HITooltip()
        tooltip.enabled = false
        options.tooltip = tooltip
        
        let plotOptions = HIPlotOptions()
        
        plotOptions.arearange = HIArearange()
        plotOptions.arearange.step = "left"
        
        plotOptions.line = HILine()
        plotOptions.line.step = "left"
        
        plotOptions.series = HISeries()
        plotOptions.series.dataLabels = HIDataLabels()
        plotOptions.series.dataLabels.enabled = true
        plotOptions.series.dataLabels.zIndex = 10
        plotOptions.series.dataLabels.x = 30
        
        plotOptions.series.lineWidth = 2
        plotOptions.series.marker = HIMarker()
        plotOptions.series.marker.enabled = false
        
        plotOptions.series.dataLabels.color = HIColor(hexValue: "000000")
        plotOptions.series.dataLabels.style = HIStyle()
        plotOptions.series.dataLabels.style.fontSize = "14px"
        plotOptions.series.dataLabels.style.fontWeight = "normal"
        plotOptions.series.dataLabels.allowOverlap = true
        plotOptions.series.dataLabels.useHTML = true
        
        plotOptions.series.dataLabels.formatter = HIFunction(jsFunction:
            "function () {"
                + "if(this.series.name == 'dynamic_line'){"
                    + "if(this.point.index !== 1 && this.point.index < this.series.yData.length - 1){"
                        + "return '<p style=\"color: #666666; background-color: #F8F8F8\">' + this.y + ',-</p>'"
                    + "}else if (this.point.index == 1){"
                        + "return '<p style=\"background-color: #F8F8F8\"><b>' + this.y + ',-</b></p>'"
                    + "}"
                + "} else if(this.series.name == 'dynamic_line_charged') {"
                    + "if(this.point.index !== 2 && this.point.index < this.series.yData.length - 1){"
                        + "return '<p style=\"color: #666666; background-color: #F8F8F8\">' + this.y + ',-</p>'"
                    + "}else if (this.point.index == 2){"
                        + "return '<p style=\"background-color: #F8F8F8\"><b>' + this.y + ',-</b></p>'"
                    + "}"
                + "} else if(this.series.name == 'dynamic_range') {"
                    + "if(this.point.index !== 0 && this.point.index < this.series.yData.length - 1){"
                        + "if(this.point.below){"
                            + "return '<p style=\"color: #666666;\"><img style=\"margin-right: 3px;transform: rotate(-90deg)\" src=\"https://assets.tillit.eu/static/public/images/back.svg\"></img>' + this.y + ',-</p>'"
                        + "} else {"
                            + "return '<p style=\"color: #666666;\"><img style=\"margin-right: 3px;transform: rotate(90deg)\" src=\"https://assets.tillit.eu/static/public/images/back.svg\"></img>' + this.y + ',-</p>'"
                        + "}"
                    + "}"
                + "}"
            + "}"
        )
        
        plotOptions.series.animation = HIAnimation()
        plotOptions.series.animation.duration = 0
        
        options.plotOptions = plotOptions
        
        options.series = [dynamic_line, dynamic_range]
        
        self.chartView.options = options
        
        self.view.addSubview(self.chartView)
        
    }
    
}
