import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let cartTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.cart", comment: ""),
        image: UIImage(systemName: "cart"),
        tag: 1
    )
    
    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.profile", comment: ""),
        image: UIImage(systemName: "person.crop.circle.fill"),
        tag: 2
    )
    
    private let statisticsTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.statistics", comment: ""),
        image: UIImage(systemName: "flag.2.crossed.fill"),
        tag: 3
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    private func configureTabBar() {
        
        let catalogController = CatalogViewController(servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
      
        let cartController = CartViewController(cartService: servicesAssembly.cartService, orderId: "1")
        let cartNavigationController = UINavigationController(rootViewController: cartController)
        cartNavigationController.tabBarItem = cartTabBarItem
        
        let statisticsController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsController)
        statisticsNavigationController.tabBarItem = statisticsTabBarItem
        
        let profileController = ProfileViewController(servicesAssembly: servicesAssembly)
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = profileTabBarItem
        
        viewControllers = [
            profileNavigationController,
            catalogNavigationController,
            cartNavigationController,
            statisticsNavigationController
        ]
        
        tabBar.unselectedItemTintColor = .black
        tabBar.tintColor = .systemBlue
        view.backgroundColor = .systemBackground
    }
}
