import UIKit

enum DisplayMode {
    case small
    case medium
    case full
}

class MiniAppViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var displayMode: DisplayMode = .small
    private var notesViewController: NotesViewController?
    private var gameViewController: XO?
    private var locationViewController: LocationViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSegmentedControl()
        // Запуск LocationViewController сразу при открытии экрана
        setupLocationViewController()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MiniAppCell.self, forCellWithReuseIdentifier: "MiniAppCell")
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    
    private func setupSegmentedControl() {
        let segmentedControl = UISegmentedControl(items: ["1/8 Screen", "1/2 Screen", "Full Screen"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    private func setupLocationViewController() {
        if locationViewController == nil {
            locationViewController = LocationViewController()
            addChild(locationViewController!)
            view.addSubview(locationViewController!.view)
            
            locationViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                locationViewController!.view.topAnchor.constraint(equalTo: view.topAnchor),
                locationViewController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                locationViewController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                locationViewController!.view.heightAnchor.constraint(equalToConstant: 200) // Adjust the height as needed
            ])
            
            locationViewController!.didMove(toParent: self)
        }
    }



    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            displayMode = .small
            collectionView.isHidden = false
            removeChildViewControllers()
            setupLocationViewController()
            collectionView.reloadData()
        case 1:
            displayMode = .medium
            collectionView.isHidden = true
            if gameViewController == nil {
                gameViewController = XO()
                addChild(gameViewController!)
                view.addSubview(gameViewController!.view)
                gameViewController!.view.frame = view.bounds
                gameViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                gameViewController!.didMove(toParent: self)
            }
            removeLocationViewController()
        case 2:
            displayMode = .full
            collectionView.isHidden = true
            if notesViewController == nil {
                notesViewController = NotesViewController()
                addChild(notesViewController!)
                view.addSubview(notesViewController!.view)
                notesViewController!.view.frame = view.bounds
                notesViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                notesViewController!.didMove(toParent: self)
            }
            removeLocationViewController()
        default:
            break
        }
    }
    
    private func removeChildViewControllers() {
        if let notesVC = notesViewController {
            notesVC.view.removeFromSuperview()
            notesVC.removeFromParent()
            notesViewController = nil
        }
        if let gameVC = gameViewController {
            gameVC.view.removeFromSuperview()
            gameVC.removeFromParent()
            gameViewController = nil
        }
    }
    
    private func removeLocationViewController() {
        if locationViewController != nil {
            locationViewController!.view.removeFromSuperview()
            locationViewController!.removeFromParent()
            locationViewController = nil
        }
    }
}

extension MiniAppViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // Количество мини-приложений
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MiniAppCell", for: indexPath) as! MiniAppCell
        
        switch displayMode {
        case .small:
            cell.configure(for: .small)
        case .medium:
            cell.configure(for: .medium)
        case .full:
            cell.configure(for: .full)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height: CGFloat
        
        switch displayMode {
        case .small:
            height = view.frame.height / 8
        case .medium:
            height = view.frame.height / 2
        case .full:
            height = view.frame.height
        }
        
        return CGSize(width: width, height: height)
    }
}

// Ячейка мини-приложения
class MiniAppCell: UICollectionViewCell {
    private let dateLabel = UILabel()
    private let label = UILabel()
    private let notesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(label)
        contentView.addSubview(notesLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8), // Поднимаем дату вверх
            
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8), // Сдвигаем label вниз от даты
            
            notesLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            notesLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
        ])
        dateLabel.textAlignment = .center
        label.textAlignment = .center
        notesLabel.textAlignment = .center
    }
    
    func configure(for mode: DisplayMode) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: Date())
        
        switch mode {
        case .small:
            dateLabel.text = dateString
            label.text = "Мини-Игра (1/8 экрана)"
            notesLabel.text = "Мини-Заметки(1/8 экрана)"
            dateLabel.isHidden = false
            notesLabel.isHidden = false
        case .medium:
            label.text = "Мини-приложение (1/2 экрана)"
            dateLabel.isHidden = true
            notesLabel.isHidden = true
        case .full:
            label.text = "Мини-приложение (Полный экран)"
            dateLabel.isHidden = true
            notesLabel.isHidden = true
        }
        
        // Уменьшение шрифта для mode == .small
        let fontSize: CGFloat = mode == .small ? 12 : 16
        label.font = UIFont.systemFont(ofSize: fontSize)
        notesLabel.font = UIFont.systemFont(ofSize: fontSize)
        dateLabel.font = UIFont.systemFont(ofSize: fontSize)
    }
}
