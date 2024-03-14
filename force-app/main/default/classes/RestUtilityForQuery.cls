/**
 * @description       : This code extends the BaseRestUtility and simplifies the interface a bit for calling the SF Rest API 'Query'
 *                      to keep the calling code tidier and less complex. Helpful to quickly pass along SOQL and get a JSON string
 *                      response back if you need to trawl it or alterntively, an untyped deserialization of the response as a map
 *                      which can readily be interrogated via the Apex Object's get method if you know the structure.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-14-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class RestUtilityForQuery extends BaseRestUtility {

    /**
     * Comes into play with calls to the EncodingUtil class. COuld live in the base class but it's not used in there yet so for now, 
     * we'll just defined it here.
     */
    public static final String ENCODING_SCHEME = 'UTF-8';

    /**
     * Standard ctor pass it through stuff
     */
    public RestUtilityForQuery() {
        super(null);
    }

    /**
     * Standard ctor pass it through stuff following the BaseRestUtility pattern of allowing a Mock to be injected
     */
    public RestUtilityForQuery(HttpCalloutMock calloutImplementation) {
        super(calloutImplementation);
    }

    /**
     * Execute the raw SOQL query returning the JSON data as string
     */
    public String executeQueryToJson(String soqlQuery)
    {
        String result = '';
        String urlEncodedSoql = EncodingUtil.urlEncode(soqlQuery, ENCODING_SCHEME);
        String uri = ORG_API_BASE_URI + '/query/?q=' + urlEncodedSoql;

        try
        {
            result = handleHttpGetRequest(uri);
        }
        catch(Exception ex)
        {
           System.debug('CAUGHT EXCEPTION in method executeQueryToJson: ' + ex.getMessage());
        }

        return result;
    }

    /**
     * Using the executeQueryToJson to make the call, take the JSON results and map them on to a map
     * which is something easier to work with if the calling code knows enough about the object structure
     * to pull data in such as:     *
     *      List<Object> records = m.get('records');
     * and so forth
     */
    public Map<String,Object> executeQueryToMap(String soqlQuery)
    {
        Map<String, Object> result = new Map<String, Object>();
        try
        {
            String jsonString = executeQueryToJson(soqlQuery);
            result = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        }
        catch(Exception ex)
        {
           System.debug('CAUGHT EXCEPTION in method executeQueryToMap: ' + ex.getMessage());
        }

        return result;
    }
}