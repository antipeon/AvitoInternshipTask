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

        model.networkSubscriber = self
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
        tableView.layer.cornerRadius = EmployeeCell.Constants.cornerRadius
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
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

    private enum Constants {
        static let tableViewWidthToWidth: CGFloat = 0.9
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.reuseId)
        guard let header = header as? HeaderView else {
            return header
        }
        header.setTitle(model.companyName)
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

        return cell
    }
}

// MARK: - NetworkSubscriber
extension MainViewController: NetworkSubscriber {
    func networkRequestDidStart() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }

    func networkResponseDidReceive() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
}
