//
//  VerticalViewController.swift
//  JSReorderableCollectionViewDemo
//
//  Created by JSilver on 20/07/2019.
//  Copyright © 2019 JSilver. All rights reserved.
//

import UIKit
import JSReorderableCollectionView

class VerticalViewController: UIViewController, JSReorderableCollectionViewDelegate {
    static let storyboardId = "VerticalViewController"
    private static let reuseIdentifier = "UICollectionViewCell"
    
    @IBOutlet var collectionViews: [JSReorderableCollectionView]!
    
    private var colors: [UIColor] = [
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1),
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vertical"
        
        collectionViews.forEach {
            $0.dataSource = self
            $0.delegate = self
            $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: VerticalViewController.reuseIdentifier)
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(gesture:)))
            $0.addGestureRecognizer(longPressGesture)
            
            $0.reorderableDelegate = self
        }
    }
    
    @objc private func longPressHandler(gesture: UILongPressGestureRecognizer) {
        guard let collectionView = gesture.view as? JSReorderableCollectionView else { return }
        
        let location = gesture.location(in: view)
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

extension VerticalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionViews[0] {
            return CGSize(width: collectionView.bounds.width - 20, height: 50)
        } else if collectionView == collectionViews[1] {
            return CGSize(width: (collectionView.bounds.width - 20) / 2, height: 50)
        } else {
            return CGSize(width: 100, height: 50)
        }
        
    }
}

extension VerticalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VerticalViewController.reuseIdentifier, for: indexPath)
        cell.layer.cornerRadius = 10
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }
}
