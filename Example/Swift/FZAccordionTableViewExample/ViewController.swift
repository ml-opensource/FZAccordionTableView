//
//  ViewController.swift
//  FZAccordionTableViewExample
//
//  Created by Krisjanis Gaidis on 10/5/15.
//  Copyright © 2015 Fuzz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    static private let kTableViewCellReuseIdentifier = "TableViewCellReuseIdentifier"
    @IBOutlet private weak var tableView: FZAccordionTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowMultipleSectionsOpen = true
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: ViewController.kTableViewCellReuseIdentifier)
        tableView.registerNib(UINib(nibName: "AccordionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)
    }
}

// MARK: - Extra Overrides - 

extension ViewController {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

// MARK: - <UITableViewDataSource> / <UITableViewDelegate> -

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AccordionHeaderView.kDefaultAccordionHeaderViewHeight
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection:section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ViewController.kTableViewCellReuseIdentifier, forIndexPath: indexPath)
        cell.textLabel!.text = "Cell"
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterViewWithIdentifier(AccordionHeaderView.kAccordionHeaderViewReuseIdentifier)
    }
}

// MARK: - <FZAccordionTableViewDelegate> -

extension ViewController : FZAccordionTableViewDelegate {

    func tableView(tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView) {
        
    }
    
    func tableView(tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView) {
        
    }
    
    func tableView(tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView) {
        
    }
    
    func tableView(tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView) {
        
    }
    
    func tableView(tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
        return true
    }
}