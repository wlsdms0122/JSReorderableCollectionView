//
//  JSReorderableCollectionView.swift
//
//  Created by JSilver on 2019/07/17.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit
import Foundation

public protocol JSReorderableCollectionViewDelegate: class {
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willSnapshot cell: UICollectionViewCell, at point: CGPoint) -> UIView
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willAppear snapshot: UIView, source cell: UICollectionViewCell, at point: CGPoint)
}

public extension JSReorderableCollectionViewDelegate {
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willSnapshot cell: UICollectionViewCell, at point: CGPoint) -> UIView {
        return cell.snapshotView(afterScreenUpdates: true)!
    }
    
    func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willAppear snapshot: UIView, source cell: UICollectionViewCell, at point: CGPoint) {
        guard let superview = collectionView.superview else { return }
        
        // Initialize cell & snapshot view
        snapshot.center = collectionView.convert(cell.center, to: superview)
        cell.isHidden = true
        
        UIView.animate(withDuration: 0.2, animations: {
            snapshot.center = point
            snapshot.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            snapshot.alpha = 0.9
        })
    }
}

open class JSReorderableCollectionView: UICollectionView {
    // MARK: - properties
    public weak var reorderableDelegate: JSReorderableCollectionViewDelegate?
    
    private var isReordering: Bool = false
    
    // Snapshot
    private var snapshot: UIView?
    private var currentPoint: CGPoint?
    
    public var isAxisFixed: Bool = false // Fix point depended on scroll direction
    
    // Index path
    private var lastIndexPath: IndexPath?
    
    // Scroll
    private var displayLink: CADisplayLink?
    private var scrollWeight: CGFloat = 0
    
    public var scrollThreshold: CGFloat = 40 // Threshold of auto scrolling (>0, pt)
    public var scrollInset: UIEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1) // Point boundary inset
    
    public var canMoveSection: Bool = false // Item can move other section
    
    private var scrollDirection: ScrollDirection {
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection ?? .vertical
    }
    
    /// Start bound of view was calced by threshold
    private var startBound: CGFloat {
        if scrollDirection == .horizontal {
            return -contentInset.left
        } else {
            return -contentInset.top
        }
    }
    
    /// End bound of view was calced by threshold
    private var endBound: CGFloat {
        if scrollDirection == .horizontal {
            return contentSize.width + contentInset.right - bounds.width
        } else {
            return contentSize.height + contentInset.bottom - bounds.height
        }
    }
    
    // MARK: - private method
    private func addScrollDisplayLink() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(scrollHandler))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    private func invalidateScrollDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// Reset point to boundary point
    /// - parameters:
    ///   - point: The point will check boundary
    ///   - frame: The bounder area
    ///   - inset: The bounder inset
    /// - returns: The point was reseted by bounder
    private func resetPoint(_ point: CGPoint, frame: CGRect, inset: UIEdgeInsets) -> CGPoint {
        return CGPoint(x: max(min(point.x, frame.origin.x + frame.size.width - inset.right), frame.origin.x + inset.left),
                       y: max(min(point.y, frame.origin.y + frame.size.height - inset.bottom), frame.origin.y + inset.top))
    }
    
    /// Reset point according to scroll axis
    /// - parameters:
    ///   - point: The point will reset according to axis
    ///   - axis: Scroll direction
    ///   - size: The view size for reset point
    /// - returns: The point was reseted by axis
    private func resetPoint(_ point: CGPoint, axis: ScrollDirection, view: UIView) -> CGPoint {
        var point = point
        if axis == .horizontal {
            point.y = view.center.y
        } else {
            point.x = view.center.x
        }
        return point
    }
    
    /// Convert point to boundary point of frame
    /// - parameters:
    ///   - point: Current point
    ///   - frame: Boundary of view of point
    ///   - isAxisFixed: Is point convert to fix by scroll axis
    /// - returns: The converted point
    private func convertPoint(_ point: CGPoint, frame: CGRect, isAxisFixed: Bool) -> CGPoint {
        // Adjust point by view boundary
        let adjustedPoint = resetPoint(point, frame: frame, inset: scrollInset)
        return isAxisFixed ? resetPoint(adjustedPoint, axis: scrollDirection, view: self) : adjustedPoint
    }
    
    /// Get index path in collection view from superview's location
    /// - parameters:
    ///   - point: The point of touch based on superview
    /// - returns: The cell index path in collection view. if cell not exist on location, return `nil`
    private func getIndexPathFromPoint(_ point: CGPoint) -> IndexPath? {
        guard let superview = superview else { return nil }
        // The index path of cell at the point in the collection view
        return indexPathForItem(at: superview.convert(point, to: self))
    }
    
    /// Move cell at source index path to destination index path
    /// - returns: return destination index path. if fail to move cell, return source index path
    private func moveCell(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> IndexPath {
        guard sourceIndexPath != destinationIndexPath else { return sourceIndexPath }
        
        // Datasource have to update before item changed of collection view
        dataSource?.collectionView?(self, moveItemAt: sourceIndexPath, to: destinationIndexPath)
        // Move cell & send message to collectionview delegate
        moveItem(at: sourceIndexPath, to: destinationIndexPath)
        
        return destinationIndexPath
    }
    
    /// Calculate auto scroll speed weight by point
    /// - parameters:
    ///   - point: point of touch based on superview
    ///   - axis: Scroll direction
    ///   - threshold: weight's threshold
    /// - returns: auto scroll factor weight(0-1) about thresholded area
    private func calcScrollWeightFromPoint(_ point: CGPoint, axis: ScrollDirection, threshold: CGFloat) -> CGFloat {
        if axis == .horizontal {
            return min(max((abs(point.x - bounds.width / 2 - frame.origin.x) - (bounds.width / 2 - CGFloat(threshold))) / threshold, 0), 1)
        } else {
            return min(max((abs(point.y - bounds.height / 2 - frame.origin.y) - (bounds.height / 2 - CGFloat(threshold))) / threshold, 0), 1)
        }
    }
    
    /// Check auto scroll need at point
    private func checkPointToScroll() {
        guard let point = currentPoint else { return }
        
        scrollWeight = calcScrollWeightFromPoint(point, axis: scrollDirection, threshold: scrollThreshold)
        if scrollWeight > 0 {
            // Need auto scroll
            if scrollDirection == .horizontal {
                if contentOffset.x >= startBound && contentOffset.x <= endBound {
                    // Check offset bound
                    addScrollDisplayLink()
                }
            } else {
                if contentOffset.y >= startBound && contentOffset.y <= endBound {
                    // Check offset bound
                    addScrollDisplayLink()
                }
            }
        } else {
            // Invalidate display link if auto scroll not need at point
            invalidateScrollDisplayLink()
        }
    }
    
    // MARK: - selector
    /// Display link handler to scroll
    @objc private func scrollHandler() {
        guard let point = currentPoint else { return }
        
        if scrollDirection == .horizontal {
            performBatchUpdates({
                if point.x > center.x {
                    // Scroll right
                    contentOffset.x = min(contentOffset.x + (10 * scrollWeight), endBound)
                } else {
                    // Scroll left
                    contentOffset.x = max(contentOffset.x - (10 * scrollWeight), startBound)
                }
            })
            
            // Invalidate display link if content offset out of bound
            if contentOffset.x <= startBound || contentOffset.x >= endBound {
                invalidateScrollDisplayLink()
            }
        } else {
            performBatchUpdates({
                if point.y > center.y {
                    // Scroll up
                    contentOffset.y = min(contentOffset.y + (10 * scrollWeight), endBound)
                } else {
                    // Scroll down
                    contentOffset.y = max(contentOffset.y - (10 * scrollWeight), startBound)
                }
            })
            
            // Invalidate display link if content offset out of bound
            if contentOffset.y <= startBound || contentOffset.y >= endBound {
                invalidateScrollDisplayLink()
            }
        }
        
        if let indexPath = getIndexPathFromPoint(point), let lastIndexPath = lastIndexPath,
            reorderableDelegate?.reorderableCollectionView(self, canMoveItemAt: indexPath) ?? false {
            if !canMoveSection && indexPath.section != lastIndexPath.section {
                finishInteractive()
                return
            }
            self.lastIndexPath = moveCell(at: lastIndexPath, to: indexPath)
        }
    }
    
    // MARK: - public method
    public func beginInteractiveWithLocation(_ location: CGPoint) {
        guard let superview = superview else { return }
        
        // Convert point
        let point = convertPoint(location, frame: frame, isAxisFixed: isAxisFixed)
        
        guard let indexPath = getIndexPathFromPoint(point), let cell = cellForItem(at: indexPath),
            reorderableDelegate?.reorderableCollectionView(self, canMoveItemAt: indexPath) ?? false else { return }
        
        // Store interaction properties
        currentPoint = point
        lastIndexPath = indexPath
        
        // Snapshot cell & add into superview's subview
        snapshot = reorderableDelegate?.reorderableCollectionView(self, willSnapshot: cell, at: point)
        superview.addSubview(snapshot!)
        
        // Display snapshot
        reorderableDelegate?.reorderableCollectionView(self, willAppear: snapshot!, source: cell, at: point)
        
        isReordering = true
    }
    
    public func updateInteractiveWithLocation(_ location: CGPoint) {
        guard isReordering else { return }
        
        // Convert point
        let point = convertPoint(location, frame: frame, isAxisFixed: isAxisFixed)
        
        currentPoint = point
        snapshot?.center = point
        
        // Move cell if it is movable
        if let indexPath = getIndexPathFromPoint(point), let lastIndexPath = lastIndexPath,
            reorderableDelegate?.reorderableCollectionView(self, canMoveItemAt: indexPath) ?? false {
            if !canMoveSection && indexPath.section != lastIndexPath.section {
                finishInteractive()
                return
            }
            
            self.lastIndexPath = moveCell(at: lastIndexPath, to: indexPath)
        }
        
        // Scroll content view if gesture location is in threshold area
        checkPointToScroll()
    }
    
    public func finishInteractive() {
        guard let superview = superview,
            let lastIndexPath = lastIndexPath,
            let cell = cellForItem(at: lastIndexPath) else { return }
    
        invalidateScrollDisplayLink()
        
        // TODO: Change to call delegate method, is available (willDisappear ...)
        UIView.animate(withDuration: 0.2, animations: {
            self.snapshot?.center = self.convert(cell.center, to: superview)
            self.snapshot?.transform = CGAffineTransform.identity
            self.snapshot?.alpha = 1.0
        }, completion: { finished in
            cell.isHidden = false
            // Initialize movable properties
            self.snapshot?.removeFromSuperview()
            self.snapshot = nil
            
            self.lastIndexPath = nil
        })
        
        isReordering = false
    }
}
