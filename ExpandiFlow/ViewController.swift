//
//  ViewController.swift
//  ExpandiFlow
//
//  Created by Logan Isitt on 10/5/17.
//  Copyright © 2017 Logan Isitt. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {
    
    private let colors: [UIColor] = [
        UIColor(red: 0.1608, green: 0.502, blue: 0.7255, alpha: 1.0),
        UIColor(red: 0.0863, green: 0.6275, blue: 0.5216, alpha: 1.0),
        UIColor(red: 0.5843, green: 0.6471, blue: 0.651, alpha: 1.0),
        UIColor(red: 0.1529, green: 0.6824, blue: 0.3765, alpha: 1.0),
        UIColor(red: 0.9059, green: 0.298, blue: 0.2353, alpha: 1.0),
        UIColor(red: 0.902, green: 0.4941, blue: 0.1333, alpha: 1.0),
        UIColor(red: 0.1725, green: 0.2431, blue: 0.3137, alpha: 1.0),
        UIColor(red: 0.8275, green: 0.3294, blue: 0, alpha: 1.0),
        UIColor(red: 0.2039, green: 0.5961, blue: 0.8588, alpha: 1.0),
        UIColor(red: 0.498, green: 0.549, blue: 0.5529, alpha: 1.0),
        UIColor(red: 0.1804, green: 0.8, blue: 0.4431, alpha: 1.0),
        UIColor(red: 0.7529, green: 0.2235, blue: 0.1686, alpha: 1.0),
        UIColor(red: 0.102, green: 0.7373, blue: 0.6118, alpha: 1.0),
        UIColor(red: 0.9529, green: 0.6118, blue: 0.0706, alpha: 1.0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let layout = collectionView?.collectionViewLayout as? ExpandiFlowLayout else { return }
        layout.columns = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 1
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Only works for 1 section right now
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.cornerRadius = 5.0
        
        if let expandiCell = cell as? ExpandiCell {
            expandiCell.textLabel.text = "\(indexPath.row)"
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let layout = collectionView.collectionViewLayout as? ExpandiFlowLayout else { return }
        
        if layout.selectedIndexPath == indexPath {
            layout.selectedIndexPath = nil
        } else {
            layout.selectedIndexPath = indexPath
        }
    }
}
