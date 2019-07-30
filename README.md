# JSReorderableCollectionView
The collection view which can drag & drop interaction of cell.

### Snapshot
<div>
<img width="300" src="./Snapshot/JSReorderableCollectionView-horizontal.gif" alt="horizontal">
<img width="300" src="./Snapshot/JSReorderableCollectionView-vertical.gif" alt="vertical">
</div>

# Requirements
- Xcode 10.2.1
- Swift 5.0
- iOS 9.0+

But it is my build setting. I think it will be fine except specific cases.

# Installation
### CocoaPods
```md
pod 'JSReorderableCollectionView', '~> 1.0.2'
```
Sorry, `Carthage` is yet.


# Usage
You have 1 class inherited `UICollectionView` and 1 protocol for `JSReorderableCollectionView`.
```swift
// JSReorderableCollectionView
open class JSReorderableCollectionView: UICollectionView {
var isAxisFixedPoint: Bool
var scrollThreshold: CGFloat
var scrollInset: UIEdgeInsets

public func beginInteractiveWithLocation(_ location: CGPoint)
public func updateInteractiveWithLocation(_ location: CGPoint)
public func finishInteractive()
}

// JSReorderableCollectionViewDelegate
public protocol JSReorderableCollectionViewDelegate: class {
func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willSnapshot cell: UICollectionViewCell, at point: CGPoint) -> UIView
func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willDisplay snapshot: UIView, source cell: UICollectionViewCell, at point: CGPoint)
}

```

- JSReorderableCollectionView
- `isAxisFixedPoint` (default `false`)

If this propery ture, select point and snapshot position will fix depend on scroll direction.

ex) Horizontal scroll collection view -> `cell`.`frame`.`center`.`y` = `collectionView`.`center`.`y`
- `scrollThreshold` (default `40`)

Auto scroll area size from both edges depend on scroll direction.
- `scrollInset` (default `1`)

Drag interaction point can't out of collection view's bounds. `scrollInset` is inset for find `indexPath` of cell on the point.

If your collection view have `contentInset` not 0, you should set this property for find `indexPath` of cell.
- `func beginInteractiveWithLocation(_ location: CGPoint)`

Start drag interaction. you should pass `CGPoint` of super view of collection view
- `func updateInteractiveWithLocation(_ location: CGPoint)`

Update cell position.
- `func finishInteractive()`

Finish drag & drop interaction.
- JSReorderableCollectionViewDelegate
- `func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, canMoveItemAt indexPath: IndexPath) -> Bool`

If your collection view have over two kind of cell type and you won't to move specific cell type, override this method.
- `func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willSnapshot cell: UICollectionViewCell, at point: CGPoint) -> UIView`

If you want to customize cell snapshot view, override this method. (default is origin snapshot of the cell)
- `func reorderableCollectionView(_ collectionView: JSReorderableCollectionView, willDisplay snapshot: UIView, source cell: UICollectionViewCell, at point: CGPoint)`

If you want to customize cell snapshot display effect or animation, override this method. (default is 1.1x size & 90% alpha)

### How to know cell moved
You can use `func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)` of `UICollectionViewDataSource`.

Send event when `moveItem` called in `func updateInteractiveWithLocation(_ location: CGPoint)`.

# Known Issue
- [ ] When the selectd cell is disappeared by auto scroll, it makes cell order look strange. but data set is fine.

It is only occur that moving between cell spaces in the collection view consist of more than one line (column or row).

# Contribution
Any idea, resolve known issue (plz resolve it T.T), new issue, PR are welcome.

# License
JSReorderableCollectionView is available under the MIT license.

