//
//  HomeSearchResultsViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/1.
//

import Foundation
import UIKit
import SnapKit

class HomeSearchResultsViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private var results: [String] = ["a","a","a","a","a","b","b","b","b","b","b","b"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension HomeSearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
}

