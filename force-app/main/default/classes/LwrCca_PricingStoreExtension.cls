/**
 * @description       : This class is current with the Spring '24 release and a part of the Salesforce Partner Learning Camp
 *                      Course "B2B Commerce: Developer Essentials" and specific to these activities:
 *
 *                          1. Implement a Shipping Provider
 *                          2. Configure a Cart Orchestrator
 *
 *                      This sample code handles the situation when the pricing behavior needs to be extended or overriden.
 *                      This is especially useful if you are sourcing pricing data from elsewhere such as in an ERP. For
 *                      Salesforce Internal Price calculation, please contult the corresponding documentation.
 *
 *                      Your custom apex class must extend the commercestorepricing.PricingService abstract base class in
 *                      order to be processed by the pricing flow. The pricing extension point and then the integration
 *                      must be linked to the webstore in the Commerce app as covered in the B2B Commerce: Developer
 *                      Essentials course.
 *
 *                      Main documentation source: https://developer.salesforce.com/docs/commerce/salesforce-commerce/guide/PricingCartCalculator.html
 *
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_PricingStoreExtension extends commercestorepricing.PricingService
{
    /***
     * You MUST change EXTERNAL_PRICING_SERVICE_HOST to  your service or you must launch your own Third Party Service and add
     * the host in Setup | Security | Remote site settings.
     */
    private static final String EXTERNAL_PRICING_SERVICE_HOST = 'https://example.com';

    /* You MUST change the USE_EXTERNAL_SERVICE to True if you want to use the Third Party Service. */
    private static final Boolean USE_EXTERNAL_SERVICE = false;

    /** The methdology to use for local shipping calculations */
    private static Enumerations.LocalPricingSource localPricingSource = Enumerations.LocalPricingSource.CONNECTAPI;

    /*
    Override processPrice method in order to change behavior of the pricing of single product.
    Fields that can be overriden are...
        At Header level:
            currency and error
        At Item level:
            unit or negotiated price, list price, pricebook entry Id, product Id and product selling model Id
    */
    public override commercestorepricing.PricingResponse processPrice(commercestorepricing.PricingRequest request)
    {
        // Extract products in request
        Set<String> products = new Set<String>();
        commercestorepricing.PricingRequestItemCollection items = request.getPricingRequestItems();

        for (Integer i = 0; i < items.size(); i++)
        {
            commercestorepricing.PricingRequestItem item = items.get(i);
            products.add(item.getProductId());
        }

        Map<String, PriceDataFromExternalService> pricesFromExternalService;

        if(USE_EXTERNAL_SERVICE)
        {
            pricesFromExternalService = getPricesFromExternalService(products);
        }
        else
        {
            pricesFromExternalService = getPriceFromStaticResponse(products);
        }

        // Create response using this data
        commercestorepricing.PricingResponse response = new commercestorepricing.PricingResponse('USD');

        //TODO: Move to iterator for consistency?
        for (Integer i = 0; i < items.size(); i++)
        {
            String productId = items.get(i).getProductId();

            if (pricesFromExternalService == null || pricesFromExternalService.get(productId) == null)
            {
                // Unsuccessful response item
                commercestorepricing.PricingResponseItem responseItem = new commercestorepricing.PricingResponseItem(
                productId,
                null,
                null,
                null,
                null
                );
                responseItem.setError(
                'No prices available for this product.',
                'Für dieses Produkt sind keine Preise verfügbar.' // TODO: <= What is this doing here?
                );
                response.addPricingResponseItem(responseItem);
            }
            else
            {
                // Successful response item
                PriceDataFromExternalService dataFromExternalService = pricesFromExternalService.get(productId);
                commercestorepricing.PricingResponseItem responseItem = new commercestorepricing.PricingResponseItem(
                    productId,
                    null,
                    null,
                    dataFromExternalService.getListPrice(),
                    dataFromExternalService.getUnitPrice()
                );

                response.addPricingResponseItem(responseItem);
            }
        }

        // Override currency using a custom mapping
        Map<String, String> mappedCurrencies = getMappedCurrencies();
        String responseCurrency = response.getCurrencyIsoCode();

        if (mappedCurrencies.containsKey(responseCurrency))
        {
            String newCurrency = mappedCurrencies.get(responseCurrency);
            response.setCurrencyIsoCode(newCurrency);
        }

        // Override unit price and list price by increasing them by a fixed amount (only for successful responses)
        Decimal fixedAmountIncrease = 10;
        commercestorepricing.PricingResponseItemCollection itemCollection = response.getPricingResponseItems();

        for (Integer i = 0; i < itemCollection.size(); i++)
        {
            commercestorepricing.PricingResponseItem item = itemCollection.get(i);

            if (item.isSuccess())
            {
                item.setListPrice(item.getListPrice() + fixedAmountIncrease);
                item.setNegotiatedPrice(item.getNegotiatedPrice() + fixedAmountIncrease);
            }
        }

        return response;
    }

    /**
    Override processTransactionalPrice method in order to change behavior of the pricing of multiple
    products within a transaction. Fields that can be overriden are...
        At header level:
            currency, error, total list price, total product  amount, total adjustment amount and total amount.
        At Item level:
            line id, product id, unit price, list price, unit pricebook entry id, unit adjustment amount,
            total line amount, total adjustment amount, total price, and total list price.
    */
    public override commercestorepricing.TransactionalPricingResponse processTransactionalPrice(commercestorepricing.TransactionalPricingRequest request2)
    {
        // Customers can easily overide the request fields. Here we increase the quantity of the first
        // item by 1.
        commercestorepricing.TransactionalPricingRequestItem reqItem = request2.getTxnPricingRequestItems().get(0);
        reqItem.setQuantity(reqItem.getQuantity() + 1);

        // Call the default internal pricing implemenation with either original request or modified
        // request
        commercestorepricing.TransactionalPricingResponse txnResponse = super.processTransactionalPrice(request2);

        // Override all string fields by appending a prefix to them in case customers use a different
        // naming convention than salesforce IDs Also increase the adjustments by a fixed amount in case
        // customer is giving a promotion for some time
        String prefix = 'XYZ_';
        Decimal fixedAdjustmentAmount = 5;
        commercestorepricing.TxnPricingResponseItemCollection txnItemCollection = txnResponse.getTxnPricingResponseItems();

        // TODO: This is dangerous - move to iterator
        for (Integer j = 0; j < txnItemCollection.size(); j++)
        {
            commercestorepricing.TransactionalPricingResponseItem txnItem = txnItemCollection.get(j);
            txnItem.setLineId(appendField(prefix, txnItem.getLineId()));
            txnItem.setProductId(appendField(prefix, txnItem.getProductId()));
            txnItem.setUnitPricePriceBookEntryId(
                appendField(prefix, txnItem.getUnitPricePriceBookEntryId())
            );
            txnItem.setTotalAdjustmentAmount(txnItem.getTotalAdjustmentAmount() - fixedAdjustmentAmount);
            txnItem.setTotalPrice(txnItem.getTotalPrice() - fixedAdjustmentAmount);
        }

        // Update the total adjustment and amount at header level accordingly
        txnResponse.setTotalAdjustmentAmount(
            txnResponse.getTotalAdjustmentAmount() - (fixedAdjustmentAmount * txnItemCollection.size()));

        txnResponse.setTotalAmount(
            txnResponse.getTotalProductAmount() + txnResponse.getTotalAdjustmentAmount());

        if (!txnItemCollection.isEmpty())
        {
            // Override success/failure of a product easily by adding an error message to the product. Here
            // we are failing the first product in the response.
            String customErrorMessage = 'We no longer sell this particular product.';
            String localizedErrorMessage = 'Wir verkaufen dieses spezielle Produkt nicht mehr.';
            txnItemCollection.get(0).setError(customErrorMessage, localizedErrorMessage);
        }

        return txnResponse;
    }

    // Given a list of product ids, get a map of their prices
    private Map<String, PriceDataFromExternalService> getPriceFromStaticResponse(Set<String> productIds)
    {
        String responseJson = '{';

        for(String productID : productIds)
        {
            Double price = 10.00;
            Double listPrice = 10.00;
            Double unitPrice = 10.00;
            responseJson = responseJson + '"'+productID+'"';
            responseJson = responseJson + ':';
            responseJson = responseJson + '{';
            responseJson = responseJson + '"listPrice"';
            responseJson = responseJson + ':';
            responseJson = responseJson + price;
            responseJson = responseJson + ',';
            responseJson = responseJson + '"unitPrice"';
            responseJson = responseJson + ':';
            responseJson = responseJson + price;
            responseJson = responseJson + '}';
            responseJson = responseJson + ',';
        }

        responseJson = responseJson.removeEnd(',') + '}';
        Map<String, Object> resultsFromExternalServiceBySKU =  (Map<String, Object>) JSON.deserializeUntyped(responseJson);

        return populatePrice(resultsFromExternalServiceBySKU);
    }

    private Map<String, PriceDataFromExternalService> populatePrice(Map<String, Object> resultsFromExternalServiceBySKU)
    {
        Map<String, PriceDataFromExternalService> priceDataFromExternalServiceBySKU = new Map<String, PriceDataFromExternalService>();

        for (String sku : resultsFromExternalServiceBySKU.keySet())
        {
            Map<String, Object> pricesFromExternalService = (Map<String, Object>) resultsFromExternalServiceBySKU.get(sku);
            priceDataFromExternalServiceBySKU.put(
                sku,
                new PriceDataFromExternalService(
                    (Decimal) pricesFromExternalService.get('listPrice'),
                    (Decimal) pricesFromExternalService.get('unitPrice')
                )
            );
        }

        return priceDataFromExternalServiceBySKU;
    }


    // This is simply a mocking of an external service call. Customers will have to change this logic to
    // call their respective services.
    private Map<String, PriceDataFromExternalService> getPricesFromExternalService(Set<String> productIds)
    {
        //TODO: Refactor this to use Base RestUtil and pass the mockign innards?
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer successfulHttpRequest = 200;

        // Encode the product IDs to avoid any invalid characters in the URL.
        Set<String> encodedProductIDs = new Set<String>();

        for (String productID : productIds)
        {
            encodedProductIDs.add(EncodingUtil.urlEncode(productID, 'UTF-8'));
        }

        // To access the service below, you may need to add endpoint =
        // httpHost in Setup > Security > Remote site settings.
        String requestURL = EXTERNAL_PRICING_SERVICE_HOST + '/get-prices?skus=' + JSON.serialize(encodedProductIDs);
        request.setEndpoint(requestURL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        // If the request is successful, parse the JSON response; The response includes the negotiated
        // as well as list price for each SKU. It looks something like this: response =
        // {"ProductID1":{"listPrice":10,"unitPrice":5}};
        if (response.getStatusCode() == successfulHttpRequest)
        {
            Map<String, Object> resultsFromExternalServiceBySKU = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return populatePrice(resultsFromExternalServiceBySKU);
        }
        else
        {
            throw new CalloutException('There was a problem with the request. Status Code: ' + response.getStatusCode());
        }
    }

    private Map<String, String> getMappedCurrencies()
    {
        Map<String, String> mappedCurrencies = new Map<String, String>();
        // TODO: Fix this so we don't get forced a price in Euros when we're USD and move keys into a static array or property
        mappedCurrencies.put('USD', 'EUR');
        // Customers can easily provide a mapping for currencies in case they do not sell in some
        // currencies or the prices are to be stored in a different currency. They can also have their
        // custom conversions defined and used.
        return mappedCurrencies;
    }

    // TODO: What's the use case exactly here - making slugs?
    @TestVisible
    private String appendField(String prefix, String field)
    {
        // Customers can easily change the string IDs returned by Salesforce Internal Pricing API
        return prefix + field;
    }

    // Stores the pricing data retrieved from external service
    class PriceDataFromExternalService
    {
        private Decimal listPrice;
        private Decimal unitPrice;

        public PriceDataFromExternalService()
        {
            listPrice = 0.0;
            unitPrice = 0.0;
        }

        public PriceDataFromExternalService(Decimal inputListPrice, Decimal inputUnitPrice)
        {
            listPrice = inputListPrice;
            unitPrice = inputUnitPrice;
        }

        // TODO: move to C# style syntax if possible?
        public Decimal getListPrice()
        {
            return listPrice;
        }

        // TODO: move to C# style syntax if possible?
        public Decimal getUnitPrice()
        {
            return unitPrice;
        }
    }
}