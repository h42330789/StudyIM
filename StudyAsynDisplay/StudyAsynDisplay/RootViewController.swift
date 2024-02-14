//
//  RootViewController.swift
//  StudyAsynDisplay
//
//  Created by MacBook Pro on 2/13/24.
//

import UIKit


class RootViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: self.view.bounds, style: .plain)
        v.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    var list: [UIViewController.Type] = [
        NormalDisplayTextVC.self,
        NormalTableViewVC.self,
        NormalDisplayListViewVC.self]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.reloadData()
        
        
    }
}

extension RootViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row+1) - \(list[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = list[indexPath.row].init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
