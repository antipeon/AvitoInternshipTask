//
//  MainViewController.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 17.10.2022.
//

import UIKit

final class MainViewController: UIViewController {

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
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderView.reuseId)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = Constants.cornerRadius
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        view.addSubview(tableView)
        view.backgroundColor = UIColor.CustomColors.backPrimary
        
        view.addSubview(activityIndicator)
        setUpConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator.startAnimating()
        model.fetchData()
    }

    
    // MARK: - Private funcs
    private func presentNetworkError(_ error: Error) {
        var message = error.localizedDescription
        
        if let error = error as? NetworkError {
            switch error {
            case .noInternetConnection, .timeout:
                message = "Check your internet connection"
            default:
                break
            }
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func initializeNetworkCallback() {
        model.networkRequestCallback = { [weak self] error in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.presentNetworkError(error)
                    return
                }
                
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Constants.tableViewWidthToWidth),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    enum Constants {
        static let tableViewWidthToWidth: CGFloat = 0.9
        static let cornerRadius: CGFloat = 20
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.reuseId)
        guard let header = header as? HeaderView else {
            return header
        }
        header.title.text = model.companyName
        return header
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
        
        let index = indexPath.item
        cell.configureWithModel(model.employees[index])
        
        cell.separatorInset = .zero
        
        guard index == 0 || index == model.employees.count - 1 else {
            return cell
        }
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = Constants.cornerRadius
        
        if index == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}
