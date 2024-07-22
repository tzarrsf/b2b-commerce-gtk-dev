/**
 * @description       : This is a custom inventory service example. It leverages a middleware component that receives the request, queries Salesforce
 *                      to get the SKU of the item and then queries the ERP system to get the quantities (On Hand, Purchased, etc) for each item and
 *                      returns the Item along with the On Hand quantity. I noticed that I could not query the Product2 records to build a map in the
 *                      APEX code to return the Product SKUs prior to making the call to the external system. Note: OCI (Omnichannel Inventory) must
 *                      be enabled in the org for inventory operations to work.
 *
 * @author            : Troy Martin (Coastal Cloud) and Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-22-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_InventoryCustom extends commerce_inventory.CommerceInventoryService
{
    /***
     * You must change this to be your service and add the host in Setup | Security | Remote site settings.
     * If you have a heroku instance you'd like to use with this class, please consult the Code It Forward charter or repository located here
     * for a one-click button deployment:
     *  https://sfdc.co/CodeItForwardCharter
     *  https://sfdc.co/CodeItForwardRepository
     * If you're a partner interested in making open source contributions you can register here:
     *  https://sfdc.co/CodeItForwardRegistration
     */
    private static String httpHost = 'https://example.com';

    public override commerce_inventory.UpsertReservationResponse upsertReservation(
        commerce_inventory.UpsertReservationRequest upsertReservationRequest,
        commerce_inventory.InventoryReservation currentReservation,
        String reservationChangeType)
    {
        system.debug('*** In the B2BCustomInventoryService.upsertReservation ***');
        system.debug('upsertReservationRequest: ' + upsertReservationRequest);
        system.debug('currentReservation: ' + currentReservation);
        system.debug('reservationChangeType: ' + reservationChangeType);

        return super.upsertReservation(upsertReservationRequest, currentReservation, reservationChangeType);
    }

    public override commerce_inventory.DeleteReservationResponse deleteReservation(String reservationId,  commerce_inventory.InventoryReservation currentReservation)
    {
        system.debug('*** In the B2BCustomInventoryService.deleteReservation ***');
        system.debug('reservationId: ' + reservationId);
        system.debug('currentReservation: ' + currentReservation);

        return super.deleteReservation(reservationId, currentReservation);
    }

    public override commerce_inventory.InventoryReservation getReservation(String reservationId)
    {
        system.debug('*** In the B2BCustomInventoryService.getReservation ***');
        system.debug('reservationId: ' + reservationId);

        return super.getReservation(reservationId);
    }

    public override commerce_inventory.InventoryCheckAvailability checkInventory(commerce_inventory.InventoryCheckAvailability request)
    {
        system.debug('*** In the B2BCustomInventoryService.checkInventory ***');
        system.debug('request: ' + request);

        return super.checkInventory(request);
    }

    public override commerce_inventory.InventoryLevelsResponse getInventoryLevel(commerce_inventory.InventoryLevelsRequest request)
    {
        // This is the method called when the Product Details Page is accessed or refreshed.
        system.debug('*** In the B2BCustomInventoryService.getInventoryLevel ***');
        system.debug('request.getInventoryLocationSourceType(): ' + request.getInventoryLocationSourceType());

        Set<commerce_inventory.InventoryLevelsItemRequest> setInvLevelItemRequest =  request.getItemInventoryLevelRequests();
        system.debug('setInvLevelItemRequest: ' + setInvLevelItemRequest);

        Set<Id> productIds = new Set<Id>();
        Item quantityFromExternalService = new Item();
        Set<commerce_inventory.InventoryLevelsItemResponse> setInvLevelItemResponse = new Set<commerce_inventory.InventoryLevelsItemResponse>();

        for (commerce_inventory.InventoryLevelsItemRequest invLevelItemRequest : setInvLevelItemRequest){
            system.debug('invLevelItemRequest: ' + invLevelItemRequest);
            system.debug('invLevelItemRequest.getProductId(): ' + invLevelItemRequest.getProductId());
            
            String productId = invLevelItemRequest.getProductId();
            quantityFromExternalService = getQuantityFromExternalService(productId);

            system.debug('invLevelItemRequest.getStockKeepingUnit(): ' + invLevelItemRequest.getStockKeepingUnit());
            system.debug('invLevelItemRequest.getLocationSourceId() : ' + invLevelItemRequest.getLocationSourceId() );

            system.debug('quantityFromExternalService: ' + quantityFromExternalService);
            
            commerce_inventory.InventoryLevelsItemResponse invLevelItemResponse = new commerce_inventory.InventoryLevelsItemResponse();

            invLevelItemResponse.setProductId(invLevelItemRequest.getProductId());
            invLevelItemResponse.setLocationSourceId(invLevelItemRequest.getLocationSourceId());
            invLevelItemResponse.setStockKeepingUnit(invLevelItemRequest.getStockKeepingUnit());
            invLevelItemResponse.setInventoryLocationSourceType(request.getInventoryLocationSourceType());
            invLevelItemResponse.setOnHand(quantityFromExternalService.quantity);
            invLevelItemResponse.setAvailableToFulfill(quantityFromExternalService.quantity);
            invLevelItemResponse.setAvailableToOrder(quantityFromExternalService.quantity);
            
            setInvLevelItemResponse.add(invLevelItemResponse);

        }

        system.debug('productIds: ' + productIds);

        commerce_inventory.InventoryLevelsResponse response = new commerce_inventory.InventoryLevelsResponse();
        response.setItemsInventoryLevels(setInvLevelItemResponse);
        return response;

    }

    private Item getQuantityFromExternalService (String productId) {
            
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer successfulHttpRequest = 200;

        request.setEndpoint(httpHost);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        
        String requestJson = '{';
        requestJson = requestJson + '"id"';
        requestJson = requestJson + ': "';
        requestJson = requestJson + productId;
        requestJson = requestJson + '"}';

        // Send the Product2.Id to the API, the middleware will query the Product2 records to look up each in ERP system.
        request.setBody(requestJson);
        request.getBody();
        system.debug('request.getBody(): ' + request.getBody()); 

        HttpResponse response = http.send(request);

        system.debug('response: ' + response); 
        system.debug('response.getBody(): ' + response.getBody()); 

        if (response.getStatusCode() == successfulHttpRequest) {
            ItemData allitemData = (ItemData)JSON.deserializeStrict(response.getBody(), ItemData.class);
            system.debug('allitemData: ' + allitemData); 
            List<Item> items = allitemData.items;
            Item itemData = items[0]; // There should only be one product returned

            return itemData;

        } else if(response.getStatusCode() == 404) {
            throw new CalloutException ('404. You must create a sample application or add your own service which returns a valid response');
        } else {
            throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
        }
    }  
    
    // This class identifies the structure of a single record in the message being returned.
    public class Item {
        public String sku;
        public Double quantity;
    }

    // This class identifies the structure of a the message being returned which is a list of items.
    public class ItemData {
        public List<Item> items;
    }
}