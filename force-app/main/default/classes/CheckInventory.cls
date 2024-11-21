global class CheckInventory {
    @InvocableMethod
    global static List<CheckInventoryResponse>getInventoryList(List<CheckInventoryRequest> requests){
        List<CheckInventoryResponse> results = new List<CheckInventoryResponse>();
        for (CheckInventoryRequest request : requests){
            results.add(getInventory(request));
        }
        return results;
    } 
    
    public static CheckInventoryResponse getInventory(CheckInventoryRequest inventoryRequest)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://inventory-apidemo-2020.herokuapp.com/inventory/product/12345');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        InventoryLocation chosenLocation = new InventoryLocation();
         chosenLocation.location = '';
         chosenLocation.quantity = 0;
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            List<Object> inventoryLocations = (List<Object>)results.get('locations');

            for (Object inventoryLocation:inventoryLocations){
                Map<String, Object> locationAttributes = (Map<String, Object>)inventoryLocation;
                 // now loop through our location attributes.
                 for (String attributeName : locationAttributes.keyset()) {
                     if (chosenLocation.quantity < (Integer)locationAttributes.get('quantity'))
                     {
                         chosenLocation.quantity = (Integer)locationAttributes.get('quantity');
                         chosenLocation.location = locationAttributes.get('location').toString();
                     }
                 }
            } 
         }
        CheckInventoryResponse inventoryResponse = new CheckInventoryResponse();
        inventoryResponse.LocationName = chosenLocation.location;
        return inventoryResponse;
    }
    
    public class InventoryLocation
    {
        String location {get;set;}
        Integer quantity {get;set;}
    }
    
    global class CheckInventoryRequest{
        @InvocableVariable(required=true)
        global String sku;
    }
    
    global class CheckInventoryResponse{
        @InvocableVariable
        global String LocationName;
    }
    
    
}