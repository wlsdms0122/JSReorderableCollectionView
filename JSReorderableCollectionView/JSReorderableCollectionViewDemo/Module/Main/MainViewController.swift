//
//  MainViewController.swift
//  JSReorderableCollectionViewDemo
//
//  Created by JSilver on 12/09/2019.
//  Copyright © 2019 JSilver. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    // MARK: - view properties
    @IBOutlet var menuTableView: UITableView!
    
    // MARK: - properties
    private var menus: [String] = [
        "Vertical Collection View",
        "Horizontal Collection View",
        "Multi-Section Collection View"
    ]
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        
        menuTableView.dataSource = self
        menuTableView.delegate = self
    }
}

// MARK: - datasource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = menus[indexPath.row]
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Collection", bundle: nil)
        
        switch indexPath.row {
        case 0:
            let viewController = storyboard.instantiateViewController(withIdentifier: "VerticalViewController")
            navigationController?.pushViewController(viewController, animated: true)
            
        case 1:
            let viewController = storyboard.instantiateViewController(withIdentifier: "HorizontalViewController")
            navigationController?.pushViewController(viewController, animated: true)
            
        case 2:
            let viewController = storyboard.instantiateViewController(withIdentifier: "MultiSectionViewController")
            navigationController?.pushViewController(viewController, animated: true)
            
        default:
            break
        }
    }
}
