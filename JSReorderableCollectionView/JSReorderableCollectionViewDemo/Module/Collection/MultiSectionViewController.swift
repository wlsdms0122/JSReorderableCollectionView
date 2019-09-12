//
//  MultiSectionViewController.swift
//  JSReorderableCollectionViewDemo
//
//  Created by JSilver on 12/09/2019.
//  Copyright © 2019 JSilver. All rights reserved.
//

import UIKit
import JSReorderableCollectionView

class MultiSectionViewController: UIViewController, JSReorderableCollectionViewDelegate {
    // MARK: - view properties
    @IBOutlet var oneCollectionView: JSReorderableCollectionView!
    
    // MARK: - properties
    private var colors: [[(Int, UIColor)]] = [
        [(1, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (2, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (3, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (4, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (5, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1))],
        [(6, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (7, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (8, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (9, UIColor(red: CGFloat.random(in: 0...1),
                    green: CGFloat.random(in: 0...1),
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (10, UIColor(red: CGFloat.random(in: 0...1),
                     green: CGFloat.random(in: 0...1),
                     blue: CGFloat.random(in: 0...1), alpha: 1))]
    ]
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Horizontal"
        
        // Register cell
        oneCollectionView.register(UINib(nibName: "ReorderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReorderCollectionViewCell")
        
        // Set delegate & datasource
        oneCollectionView.dataSource = self
        oneCollectionView.delegate = self
        
        // Add gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(gesture:)))
        oneCollectionView.addGestureRecognizer(longPressGesture)
        
        oneCollectionView.reorderableDelegate = self
    }
    
    // MARK: - selector
    @objc private func longPressHandler(gesture: UILongPressGestureRecognizer) {
        guard let collectionView = gesture.view as? JSReorderableCollectionView else { return }
        
        let location = gesture.location(in: collectionView.superview!)
        
        switch gesture.state {
        case .began:
            collectionView.beginInteractiveWithLocation(location)
            
        case .changed:
            collectionView.updateInteractiveWithLocation(location)
            
        default:
            collectionView.finishInteractive()
        }
    }
}

extension MultiSectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReorderCollectionViewCell", for: indexPath) as? ReorderCollectionViewCell else {
            fatalError()
        }
        
        cell.textLabel.text = String(colors[indexPath.section][indexPath.row].0)
        cell.backgroundColor = colors[indexPath.section][indexPath.row].1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let color = colors[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        colors[destinationIndexPath.section].insert(color, at: destinationIndexPath.row)
    }
}

extension MultiSectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == oneCollectionView {
            return CGSize(width: collectionView.bounds.width, height: 60)
        }
        
        return .zero
    }
}
