//
//  ViewController.swift
//  JSReorderableCollectionViewDemo
//
//  Created by JSilver on 20/07/2019.
//  Copyright © 2019 JSilver. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let menus: [String] = [
        "Horizontal",
        "Vertical"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = menus[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let vc = storyboard?.instantiateViewController(withIdentifier: HorizontalViewController.storyboardId) else { return }
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            guard let vc = storyboard?.instantiateViewController(withIdentifier: VerticalViewController.storyboardId) else { return }
            navigationController?.pushViewController(vc, animated: true)
        default:
            fatalError()
        }
    }
}
