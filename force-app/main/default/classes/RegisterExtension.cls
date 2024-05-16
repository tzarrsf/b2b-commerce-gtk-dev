/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 05-16-2024
 * @last modified by  : Tom Zarr
**/
public class RegisterExtension {
    public static void registerExtension(
            String registeredExtensionName,
            String extensionPointName,
            String namespace,
            String apexClassname,
            Double apexApiVersion) {
        
        // ApexClass query values
        String status = 'Active';
    
        if (apexApiVersion == null) {
            apexApiVersion = 61.0;
        }
    
        // RegisteredExternalService insert values
        String registeredProviderType = 'Extension';
    
        ApexClass apexClass;
        // locate apex class Id
        if (namespace != null) {
            apexClass = [
                    SELECT Id FROM ApexClass WHERE
                            Status = :status AND
                            NamespacePrefix = :namespace AND
                            ApiVersion = :apexApiVersion AND
                            Name = :apexClassname
                    LIMIT 1
            ];
        } else {
            apexClass = [
                    SELECT Id FROM ApexClass WHERE
                            Status = :status AND
                            Name = :apexClassname AND
                            ApiVersion = :apexApiVersion
                    LIMIT 1
            ];
        }
    
        String apexClassId = apexClass.Id;
    
        String registeredIntegrationId = null;
        try {
            insert new RegisteredExternalService(
                    DeveloperName = registeredExtensionName,
                    MasterLabel = registeredExtensionName,
                    ExternalServiceProviderId = apexClassId,
                    ExtensionPointName = extensionPointName,
                    ExternalServiceProviderType = registeredProviderType
            );
    
            RegisteredExternalService registeredExternalService = [
                    SELECT Id FROM RegisteredExternalService WHERE
                            ExternalServiceProviderId =: apexClassId AND
                            DeveloperName =: registeredExtensionName AND
                            ExtensionPointName =: extensionPointName LIMIT 1
            ];
    
            registeredIntegrationId = registeredExternalService.Id;
            System.debug('extension registration [SUCCESS]: ' + registeredIntegrationId);
        } catch (DmlException q) {
            System.debug('extension registration [FAILED]: ' + q);
        }
    }
    
    public static void associateWithWebstore(String webstoreName, String registeredExtensionName) {
    
        String registeredProviderType = 'Extension';
    
        WebStore webStore = [
                SELECT Id FROM WebStore WHERE Name = :webstoreName LIMIT 1
        ];
        String webStoreId = webStore.Id;
        System.debug('webStoreId:' + webStoreId);
    
        //Note the use of new extensionPointName variable in this query.
        List<RegisteredExternalService> registeredServices =
            [
                    SELECT Id FROM RegisteredExternalService WHERE DeveloperName=:registeredExtensionName LIMIT 1
            ];
    
        String registeredIntegrationId = (null != registeredServices && registeredServices.size() > 0)? registeredServices.get(0).Id : null;
    
        System.debug('apex registration:' + registeredIntegrationId);
        // locate and map in StoreIntegratedService
        try {
            //note the use of registered external service id
            List<StoreIntegratedService> storeServices = [
                SELECT Integration,ServiceProviderType,StoreId FROM StoreIntegratedService WHERE
                    Integration = :registeredIntegrationId AND ServiceProviderType = :registeredProviderType AND StoreId = :webStoreId
            ];
            if (null == storeServices || storeServices.size() == 0) {
                storeServices = new List<StoreIntegratedService> { 
                    new StoreIntegratedService(Integration = registeredIntegrationId, ServiceProviderType = registeredProviderType, StoreId = webStoreId) 
                };
            }
            upsert storeServices;
            System.debug('Mapping to webstore [SUCCESS]: ' + storeServices);
        } catch (QueryException q) {
            System.debug('Mapping to webstore [FAILED]: ' + q);
    
        }
    }
    
    public enum ExtensionType { ORCHESTRATOR,INVENTORY,CALCULATOR_PRICE,CALCULATOR_PROMOTION, CALCULATOR_SHIPPING, SPLIT_SHIPMENT, CALCULATOR_TAX }
    
    public static void register(String apexClassName, RegisterExtension.ExtensionType extensionType) {
        String registeredExtensionName = null;
        switch on extensionType {
            when ORCHESTRATOR { registeredExtensionName = 'Commerce_Domain_Cart_Calculate'; }
            when INVENTORY { registeredExtensionName = 'Commerce_Domain_Inventory_CartCalculator'; }
            when CALCULATOR_PRICE { registeredExtensionName = 'Commerce_Domain_Pricing_CartCalculator'; }
            when CALCULATOR_PROMOTION { registeredExtensionName = 'Commerce_Domain_Promotions_CartCalculator'; }
            when CALCULATOR_SHIPPING { registeredExtensionName = 'Commerce_Domain_Shipping_CartCalculator'; }
            when SPLIT_SHIPMENT { registeredExtensionName = 'Commerce_Domain_Shipping_SplitShipment'; }
            when CALCULATOR_TAX { registeredExtensionName = 'Commerce_Domain_Tax_CartCalculator'; }
     
        }
        final Double apexApiVersion = 61.0; // @TODO UPDATE
        if (null != registeredExtensionName) {
            registerExtension(registeredExtensionName, registeredExtensionName, null, apexClassName,apexApiVersion); 
        }
    }
    
    public static void associate(String webStoreName, RegisterExtension.ExtensionType extensionType) {
        String registeredExtensionName = null;
        switch on extensionType {
            when ORCHESTRATOR { registeredExtensionName = 'Commerce_Domain_Cart_Calculate'; }
            when INVENTORY { registeredExtensionName = 'Commerce_Domain_Inventory_CartCalculator'; }
            when CALCULATOR_PRICE { registeredExtensionName = 'Commerce_Domain_Pricing_CartCalculator'; }
            when CALCULATOR_PROMOTION { registeredExtensionName = 'Commerce_Domain_Promotions_CartCalculator'; }
            when CALCULATOR_SHIPPING { registeredExtensionName = 'Commerce_Domain_Shipping_CartCalculator'; }
            when CALCULATOR_TAX { registeredExtensionName = 'Commerce_Domain_Tax_CartCalculator'; }
        }
        if (null != registeredExtensionName && null != webStoreName) {
            associateWithWebstore(webStoreName, registeredExtensionName);
        }
    }
}