import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    let servicesAssembly = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl(),
        myNftStorage: MyNftStorageImpl()
    )

    func scene(_: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        let tabBarController = window?.rootViewController as? TabBarController
        tabBarController?.servicesAssembly = servicesAssembly
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        sendLikesToServer()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        sendLikesToServer()
    }

    private func sendLikesToServer() {
        let likes = LikesStorageImpl.shared.getAllLikes()
        servicesAssembly.profileService.updateLikes(likes: likes) { result in
            switch result {
            case .success:
                print("Лайки успешно отправлены перед выходом из приложения.")
            case .failure(let error):
                print("Ошибка отправки лайков: \(error.localizedDescription)")
            }
        }
    }
}
