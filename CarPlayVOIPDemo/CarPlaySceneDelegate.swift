import CarPlay

//
//  Untitled.swift
//  CarPlayVOIPDemo
//
//  Created by Arunesh Rathore on 15/07/25.
//

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        CarPlayManager.shared.setInterfaceController(interfaceController)
        
        // Set up the main CarPlay interface
        let mainTemplate = CarPlayManager.shared.createMainTemplate()
        interfaceController.setRootTemplate(mainTemplate, animated: true, completion: nil)
    }
    
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
        CarPlayManager.shared.setInterfaceController(nil)
    }
}

