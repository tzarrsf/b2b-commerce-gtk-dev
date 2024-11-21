/**
 * @description       : This is an abstraction (template in design pattern speak) for a Tax Provider. It's particularly useful for
 *                      encapsulating data and behavior to facilitate quick change out and create fungible tax provider resources.
 *                      Use of this class makes swapping out something like Avalara for Vertex or vice versa much easier.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 11-20-2024
 * @last modified by  : Tom Zarr
**/
public abstract class LwrCca_TaxAbstractProvider {

    // TODO: Remove this if descendants aren't needing it - they shouldn't AFAIK
    public LwrCca_TaxAbstractProvider() {}

    public virtual Map<String, String> prepareNamedCredentials(LwrCca_TaxProviderRequest taxRequest)
    {
      Map<String, String> callOutRequest = new Map<String, String>();
      String endPoint =
        Constants.CALLOUT +
        taxRequest.taxMetaData.namedCredentials +
        taxRequest.taxMetaData.endPoint;
      callOutRequest.put(Constants.END_POINT, endPoint);
      // callOutRequest.put(Constants.USERNAME , Constants.CREDENNTIALS_USERNAME);
      // callOutRequest.put(Constants.PASSWORD , Constants.CREDENNTIALS_PASSWORD);
      return callOutRequest;
    }

    public virtual Map<String, String> setServiceDetails(LwrCca_TaxProviderRequest taxRequest)
    {
      Map<String, String> serviceDetails = new Map<String, String>();
      serviceDetails.put(Constants.HTTP_METHOD, taxRequest.taxMetaData.httpMethod);
      serviceDetails.put(Constants.SERVICE_TIMEOUT, taxRequest.taxMetaData.serviceTimeout);
      serviceDetails.put(Constants.SERVICE_MODE, taxRequest.taxMetaData.serviceMode);
      serviceDetails.put(Constants.MOCKED_RESPONSE, taxRequest.taxMetaData.mockedResponse);

      return serviceDetails;
    }

    public virtual Map<String, String> setRequestHeaders(LwrCca_TaxProviderRequest taxRequest)
    {
        Map<String, String> htttpRequestDetails = new Map<String, String>();

        return htttpRequestDetails;
    }

    public virtual LwrCca_TaxProviderResponse calculateTax(LwrCca_TaxProviderRequest taxRequest)
    {
        LwrCca_TaxProviderResponse taxes;
        Map<String, String> responseMap;
        Boolean calloutSuccess = true;

        try
        {
            Map<String, String> callOutRequest = new Map<String, String>();
            callOutRequest.putAll(prepareNamedCredentials(taxRequest));
            callOutRequest.putAll(setServiceDetails(taxRequest));
            prepareCreateTransaction(taxRequest, callOutRequest);

            responseMap = ServiceFactory.getService(taxRequest.taxMetaData.serviceImplClass)
                .makeExternalCallout(callOutRequest, setRequestHeaders(taxRequest));

            if(Constants.HTTP_RESPONSE_STATUS_ERROR.equals(responseMap.get(Constants.HTTP_RESPONSE_STATUS)) || responseMap.isEmpty())
            {
                calloutSuccess = false;
            }

            String response = responseMap.get(Constants.SERVICE_RESPONSE_BODY);

            if (calloutSuccess)
            {
                taxes = getTaxFromResponse(response, taxRequest);
            }
        }
        catch (Exception exceptionObject)
        {
            System.debug('Exception due to error ====' + exceptionObject.getMessage() + 'at Line Number ====' + exceptionObject.getLineNumber());
            /**
             * TODO: Best Practice: Never swallow exceptions without doing something else meaningfull. You should add your firm's preferred
             * approach whether logging, retrying, pivoting to a backup resource or pulling local values to name a few approaches.
             */
        }

        return taxes;
    }

    public abstract LwrCca_TaxProviderResponse getTaxFromResponse(String response, LwrCca_TaxProviderRequest taxRequest);

    public abstract void prepareCreateTransaction(LwrCca_TaxProviderRequest taxRequest, Map<String, String> callOutRequest);

    public void commitTransaction(LwrCca_TaxProviderRequest taxRequest)
    {
      System.debug('========================= Inside LwrCca_AbstractTaxProvider#calculateTax starts');

      LwrCca_TaxProviderResponse taxes;
      Map<String, String> responseMap;
      Boolean calloutSuccess = true;

      try
      {
        Map<String, String> callOutRequest = new Map<String, String>();
        callOutRequest.putAll(prepareNamedCredentials(taxRequest));
        callOutRequest.putAll(setServiceDetails(taxRequest));
        prepareCommitTransaction(taxRequest, callOutRequest);

        responseMap = ServiceFactory.getService(taxRequest.taxMetaData.serviceImplClass)
          .makeExternalCallout(callOutRequest, setRequestHeaders(taxRequest));

        if (!'201'.equals(responseMap.get(Constants.RESPONSE_REASON_CODE)) || responseMap.isEmpty())
        {
            calloutSuccess = false;
        }

        String response = responseMap.get(Constants.SERVICE_RESPONSE_BODY);

        if (calloutSuccess)
        {
            taxes = getTaxFromResponse(response, taxRequest);
        }
      }
      catch (Exception exceptionObject)
      {
        System.debug('Exception due to error ====' + exceptionObject.getMessage() + 'at Line Number ====' + exceptionObject.getLineNumber());
        /**
         * TODO: Best Practice: Never swallow exceptions without doing something else meaningfull. You should add your firm's preferred
         * approach whether logging, retrying, pivoting to a backup resource or pulling local values to name a few approaches.
         */
      }
    }

    public abstract void prepareCommitTransaction(LwrCca_TaxProviderRequest taxRequest, Map<String, String> callOutRequest);
}