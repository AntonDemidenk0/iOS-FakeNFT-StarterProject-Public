import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalogController = CatalogViewController(servicesAssembly: servicesAssembly)
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.catalog", comment: ""),
            image: UIImage(systemName: "person.crop.rectangle.stack.fill"),
            tag: 0
        )

        viewControllers = [catalogNavigationController]

        view.backgroundColor = .systemBackground
    }
}
