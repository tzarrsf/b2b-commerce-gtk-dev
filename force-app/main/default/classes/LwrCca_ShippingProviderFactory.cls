/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-14-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class LwrCca_ShippingProviderFactory {
  private static LwrCca_AbstractShippingProvider LwrCca_AbstractShippingProvider;
  private static Map<String, LwrCca_AbstractShippingProvider> shippingProviders = new Map<String, LwrCca_AbstractShippingProvider>();
  private LwrCca_ShippingProviderFactory() {
  }
  public static LwrCca_AbstractShippingProvider getShippingProvider(
    LwrCca_ShippingMetaData LwrCca_ShippingMetaData
  ) {
    if (shippingProviders.containsKey(LwrCca_ShippingMetaData.providerImplClass)) {
      LwrCca_AbstractShippingProvider = shippingProviders.get(LwrCca_ShippingMetaData.providerImplClass);
    } else {
      if (LwrCca_ShippingMetaData.providerImplClass != null) {
        Type t = Type.forName(LwrCca_ShippingMetaData.providerImplClass);
        LwrCca_AbstractShippingProvider = (LwrCca_AbstractShippingProvider) t.newInstance();
        shippingProviders.put(LwrCca_ShippingMetaData.providerImplClass,LwrCca_AbstractShippingProvider);
      }
    }
    return LwrCca_AbstractShippingProvider;
  }
}