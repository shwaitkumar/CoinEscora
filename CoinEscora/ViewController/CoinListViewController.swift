//
//  CoinListViewController.swift
//  CoinEscora
//
//  Created by Shwait Kumar on 25/01/23.
//

import UIKit

class CoinListViewController: UIViewController {
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Coin>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Coin>
    
    private var collectionView: UICollectionView! = nil
    
    private var dataSource: Datasource!
    
    enum Section: CaseIterable {
        case allCoins
    }
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var loadedCount = 0
    private var loadingInProgress = false
    private lazy var bottomLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let bottomBar: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.layer.cornerRadius = 25
        visualEffectView.clipsToBounds = true
        return visualEffectView
    }()
    
    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Search Coins"
        return searchController
    }()
    
    var coinList = [Coin]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(named: "Background")
        title = "All Coins"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        configureCollectionView()
        setupLoadingIndicator()
        setupBottomBar()
        configureDataSource()
        fetchCoinList()
    }
    
}

// MARK: - Call API
extension CoinListViewController {
    private func fetchCoinList() {
        loadingIndicator.startAnimating()
        SimpleNetworkHelper.shared.fetchCoins(completion: { (coins) in
            if let coins = coins {
                self.coinList = coins
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.loadData(isInitialLoad: true) // first time hide loader at bottom
                }
            }
        })
    }
}

// MARK: - Helper Method
extension CoinListViewController {
    // Create Snapshot of 25 items and add to datasource
    func loadData(isInitialLoad: Bool = false, isAfterSearch: Bool = false) {
        // Reset search results and show original loaded list again
        if isAfterSearch == true {
            let newLoadedCount = 0
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections([.allCoins])
            
            for coinIndex in newLoadedCount..<coinList.count {
                if coinIndex == newLoadedCount + loadedCount {
                    break
                }
                let coinAtIndex = (coinList[coinIndex])
                snapshot.appendItems([coinAtIndex], toSection: .allCoins)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.dataSource.apply(snapshot, animatingDifferences: true)
                self.loadedCount = snapshot.numberOfItems
            }
        }
        else { // load coin list in group of 50 items
            guard dataSource.snapshot().numberOfItems < coinList.count else { return }
            guard !loadingInProgress else { return }
            loadingInProgress = true
            if isInitialLoad == false {
                bottomLoadingIndicator.startAnimating()
            }
            
            var snapshot = dataSource.snapshot()
            if snapshot.numberOfSections == 0 {
                snapshot.appendSections([.allCoins])
            }
            
            for coinIndex in loadedCount..<coinList.count {
                if coinIndex == loadedCount + 50 {
                    break
                }
                let coinAtIndex = (coinList[coinIndex])
                snapshot.appendItems([coinAtIndex], toSection: .allCoins)
            }
            
            let loadTime: TimeInterval = isInitialLoad ? 0 : 1.4
            DispatchQueue.main.asyncAfter(deadline: .now() + loadTime) {
                self.dataSource.apply(snapshot, animatingDifferences: true)
                self.loadedCount = snapshot.numberOfItems
                self.loadingInProgress = false
                self.bottomLoadingIndicator.stopAnimating()
                if self.bottomBar.isHidden == true {
                    self.bottomBar.isHidden = false
                    self.bottomLabel.isHidden = false
                }
                self.bottomLabel.text = "Showing \(self.loadedCount)/\(self.coinList.count) Coins"
            }
        }
    }
}

// MARK: - Setup CollectionView & Layout
extension CoinListViewController {
    private func setupLoadingIndicator() {
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubview(loadingIndicator)
        view.addSubview(bottomLoadingIndicator)
        
        // Show loading indiactor at start in the middle
        NSLayoutConstraint.activate([
            layoutGuide.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            layoutGuide.centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor),
            
            // Bottom Loading Indicator
            layoutGuide.centerXAnchor.constraint(equalTo: bottomLoadingIndicator.centerXAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: bottomLoadingIndicator.bottomAnchor, constant: 80)
        ])
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(collectionView)
        
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .clear
        configuration.separatorConfiguration.color = UIColor(named: "Seperator") ?? .separator
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func setupBottomBar() {
        view.addSubview(bottomBar)
        view.addSubview(bottomLabel)
        
        bottomBar.isHidden = true
        bottomLabel.isHidden = true
        
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomBar.heightAnchor.constraint(equalToConstant: 50),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            
            bottomLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            bottomLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: bottomLabel.leadingAnchor, constant: -20),
            bottomBar.trailingAnchor.constraint(equalTo: bottomLabel.trailingAnchor, constant: 20)
        ])
    }

}

// MARK: - CollectionView Datasource
extension CoinListViewController {
    private func configureDataSource() {
        // list cell
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Coin> { (cell, indexPath, coin) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = coin.name
            contentConfiguration.secondaryText = coin.symbol
            cell.contentConfiguration = contentConfiguration
            
            cell.accessories = [.disclosureIndicator()]
        }
        
        // data source
        dataSource = UICollectionViewDiffableDataSource<Section, Coin>(collectionView: collectionView) {
            (collectionView, indexPath, coin) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: coin)
        }
    }

}

// MARK: - CollectionView Delegate
extension CoinListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let vc = CoinDetailViewController()
        vc.title = dataSource.itemIdentifier(for: indexPath)?.name
        vc.coin = dataSource.itemIdentifier(for: indexPath)
        debugPrint("Coin Id - ", dataSource.itemIdentifier(for: indexPath)?.id as Any)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard loadedCount != 0 else { return }
        
        // displaying last item
        if indexPath.row == loadedCount - 1 {
            loadData()
        }
    }
}

// MARK: - Search Controller Delegate
extension CoinListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if !searchController.isActive {
            loadData(isAfterSearch: true) // clear search results and show all coin list
        }
        else {
            let filteredCoins = coinList.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            var snapshot = Snapshot()
            snapshot.appendSections([.allCoins])
            snapshot.appendItems(filteredCoins, toSection: .allCoins)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        searchController.searchBar.resignFirstResponder()
        searchController.isActive = false
        //clear search results and show all coin list again
        loadData(isAfterSearch: true)
    }

}

