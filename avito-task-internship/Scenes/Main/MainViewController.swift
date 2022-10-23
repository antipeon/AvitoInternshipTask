//
//  MainViewController.swift
//  avito-task-internship
//
//  Created by Samat Gaynutdinov on 17.10.2022.
//

import UIKit

protocol MainDisplayLogic: AnyObject {
    func displayStartLoading(viewModel: Main.FetchData.ViewModel.Dummy)
    func presentError(viewModel: Main.FetchData.ViewModel.Error)
    func presentCompanyData(viewModel: Main.FetchData.ViewModel.Company)
    func displayFinishLoading(viewModel: Main.FetchData.ViewModel.Dummy)
}

final class MainViewController: UIViewController, MainDisplayLogic, UITableViewDelegate, UITableViewDataSource {
    var interactor: MainBusinessLogic?

    // expose for testing
    var displayedModel = Main.FetchData.ViewModel.Company(company: CompanyNetworkModel())

    // MARK: - Subviews

    // expose tableView to mock for tests
    lazy var tableView: UITableView = {
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
        let request = Main.FetchData.Request()
        interactor?.fetchData(request: request)
    }

    // MARK: - MainDisplayLogic
    func presentError(viewModel: Main.FetchData.ViewModel.Error) {
        let alert = UIAlertController(title: "Error", message: viewModel.errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func presentCompanyData(viewModel: Main.FetchData.ViewModel.Company) {
        displayedModel = viewModel
        tableView.reloadData()
    }

    func displayStartLoading(viewModel: Main.FetchData.ViewModel.Dummy) {
        activityIndicator.startAnimating()
    }

    func displayFinishLoading(viewModel: Main.FetchData.ViewModel.Dummy) {
        activityIndicator.stopAnimating()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedModel.company.employees.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EmployeeCell.reuseId, for: indexPath)

        guard let cell = cell as? EmployeeCell else {
            return cell
        }

        let index = indexPath.item
        cell.configureWithModel(displayedModel.company.employees[index])

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.reuseId)
        guard let header = header as? HeaderView else {
            return header
        }
        header.setTitle(displayedModel.company.name)
        return header
    }

    // MARK: - Private funcs
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
