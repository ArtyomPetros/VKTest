import UIKit

class XO: UIViewController {
    
    private let boardSize = 3
    private var board: [[String]] = []
    private var currentPlayer = "X"
    private let buttonSize: CGFloat = 100
    private let spacing: CGFloat = 10
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupScrollView()
        setupBoard()
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.gray.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Constraints for scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Constraints for contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Set contentView width equal to scrollView width
        ])
        
    }
    
    private func setupBoard() {
        board = Array(repeating: Array(repeating: " ", count: boardSize), count: boardSize)
        setupButtons()
    }
    
    private func setupButtons() {
        let totalWidth = CGFloat(boardSize) * buttonSize + CGFloat(boardSize - 1) * spacing
        let startX = (view.bounds.width - totalWidth) / 2
        let startY = (totalWidth / 2) - 150 // Raise the board by 50 points
        
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let button = UIButton(frame: CGRect(x: startX + CGFloat(col) * (buttonSize + spacing),
                                                    y: startY + CGFloat(row) * (buttonSize + spacing),
                                                    width: buttonSize,
                                                    height: buttonSize))
                button.tag = row * boardSize + col
                button.setTitle(" ", for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 64)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = currentPlayer == "X" ? .yellow : .systemGreen
                button.layer.cornerRadius = buttonSize / 10 // Set corner radius
                button.clipsToBounds = true // Clip content to bounds
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                contentView.addSubview(button)
            }
        }
        
        // Constraints for contentView (height and width)
        let totalHeight = CGFloat(boardSize) * buttonSize + CGFloat(boardSize - 1) * spacing
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: totalHeight),
            contentView.widthAnchor.constraint(equalToConstant: view.bounds.width)
        ])
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        let row = sender.tag / boardSize
        let col = sender.tag % boardSize
        
        if board[row][col] == " " {
            board[row][col] = currentPlayer
            sender.setTitle(currentPlayer, for: .normal)
            sender.setTitleColor(currentPlayer == "X" ? .black : .blue, for: .normal) // Set color based on the player
            animateButton(sender) // Add animation
            
            if checkWin() {
                showAlert(message: "\(currentPlayer) wins!")
                return
            } else if checkDraw() {
                showAlert(message: "It's a draw!")
                return
            }
            currentPlayer = (currentPlayer == "X") ? "O" : "X"
        }
    }
    
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1,
                       animations: {
                           button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                       }, completion: { _ in
                           UIView.animate(withDuration: 0.1) {
                               button.transform = CGAffineTransform.identity
                           }
                       })
    }
    
    private func checkWin() -> Bool {
        // Check rows
        for row in 0..<boardSize {
            if board[row][0] != " " && board[row][0] == board[row][1] && board[row][1] == board[row][2] {
                return true
            }
        }
        // Check columns
        for col in 0..<boardSize {
            if board[0][col] != " " && board[0][col] == board[1][col] && board[1][col] == board[2][col] {
                return true
            }
        }
        // Check diagonals
        if board[0][0] != " " && board[0][0] == board[1][1] && board[1][1] == board[2][2] {
            return true
        }
        if board[0][2] != " " && board[0][2] == board[1][1] && board[1][1] == board[2][0] {
            return true
        }
        return false
    }
    
    private func checkDraw() -> Bool {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if board[row][col] == " " {
                    return false
                }
            }
        }
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            self.resetBoard()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func resetBoard() {
        board = Array(repeating: Array(repeating: " ", count: boardSize), count: boardSize)
        for view in contentView.subviews {
            if let button = view as? UIButton {
                button.setTitle(" ", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = currentPlayer == "X" ? .systemRed : .systemGreen // Reset background color
            }
        }
        currentPlayer = "X"
    }
}
