//
//  MainViewController.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 17.10.2022.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - Private vars
    private let model: MainModel
    
    // MARK: - init
    init(model: MainModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        
        initializeNetworkCallback()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Subviews
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EmployeeCell.self, forCellReuseIdentifier: EmployeeCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view = tableView
        view.backgroundColor = .white
        
        view.addSubview(activityIndicator)
        setUpConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator.startAnimating()
        model.fetchData()
    }

    
    // MARK: - Private funcs
    private func presentNetworkError(_ error: Error) {
        // TODO: implement alert
    }
    
    private func initializeNetworkCallback() {
        model.networkRequestCallback = { [weak self] error in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.presentNetworkError(error)
                    return
                }
                
                self.tableView.reloadData()
                self.tableView.setNeedsLayout()
                self.tableView.layoutIfNeeded()
            }
        }
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        model.companyName
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmployeeCell.reuseId, for: indexPath)
        
        guard let cell = cell as? EmployeeCell else {
            return cell
        }
        
        cell.configureWithModel(model.employees[indexPath.row])
        return cell
    }
    
    
}
