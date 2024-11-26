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
        image: UIImage(resource: .cart),
        tag: 2
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = CatalogViewController(servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
      
        let cartController = CartViewController(cartService: servicesAssembly.cartService,orderId: "1")
        cartController.tabBarItem = cartTabBarItem
      
        viewControllers = [catalogNavigationController, cartController]

        view.backgroundColor = .systemBackground
    }
}