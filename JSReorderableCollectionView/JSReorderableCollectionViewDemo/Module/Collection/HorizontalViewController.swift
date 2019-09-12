//
//  HorizontalViewController.swift
//  JSReorderableCollectionViewDemo
//
//  Created by JSilver on 12/09/2019.
//  Copyright © 2019 JSilver. All rights reserved.
//

import UIKit
import JSReorderableCollectionView

class HorizontalViewController: UIViewController, JSReorderableCollectionViewDelegate {
    // MARK: - view properties
    @IBOutlet var oneCollectionView: JSReorderableCollectionView!
    @IBOutlet var twoCollectionView: JSReorderableCollectionView!
    
    // MARK: - properties
    private var colors: [(Int, UIColor)] = [
        (1, UIColor(red: CGFloat.random(in: 0...1),
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
                    blue: CGFloat.random(in: 0...1), alpha: 1)),
        (6, UIColor(red: CGFloat.random(in: 0...1),
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
                     blue: CGFloat.random(in: 0...1), alpha: 1))
    ]
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Horizontal"
        
        [oneCollectionView, twoCollectionView].forEach {
            // Register cell
            $0?.register(UINib(nibName: "ReorderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReorderCollectionViewCell")
            
            // Set delegate & datasource
            $0?.dataSource = self
            $0?.delegate = self
            
            // Add gesture recognizer
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(gesture:)))
            $0?.addGestureRecognizer(longPressGesture)
            
            $0?.reorderableDelegate = self
        }
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

extension HorizontalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReorderCollectionViewCell", for: indexPath) as? ReorderCollectionViewCell else {
            fatalError()
        }
        
        cell.textLabel.text = String(colors[indexPath.row].0)
        cell.backgroundColor = colors[indexPath.row].1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let color = colors.remove(at: sourceIndexPath.row)
        colors.insert(color, at: destinationIndexPath.row)
        
        if collectionView == oneCollectionView {
            twoCollectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        } else {
            oneCollectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        }
    }
}

extension HorizontalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == oneCollectionView {
            return CGSize(width: 50, height: collectionView.bounds.height)
        } else if collectionView == twoCollectionView {
            return CGSize(width: 100, height: 100)
        }
        
        return .zero
    }
}
