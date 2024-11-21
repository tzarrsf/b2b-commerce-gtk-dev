/**
 * @description       : Concrete provider fulfilling the LwrCca_TaxAbstractProvider template requirements.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 11-20-2024
 * @last modified by  : Tom Zarr
**/

public without sharing class LwrCca_TaxAvalaraProvider extends LwrCca_TaxAbstractProvider
{

    public LwrCca_TaxAvalaraProvider() {}

    public override void prepareCreateTransaction(LwrCca_TaxProviderRequest taxRequest,Map<String, String> callOutRequest)
    {
        Boolean hasMultipleShipments = taxRequest.hasMultipleShipments != null && taxRequest.hasMultipleShipments == true ? true: false;

        LwrCca_TaxAvalaraRequest avalaraRequest = new LwrCca_TaxAvalaraRequest();
        avalaraRequest.type = taxRequest.taxTransacionType;
        avalaraRequest.currencyCode = taxRequest.currencyCode;
        avalaraRequest.commit_Z = taxRequest.taxMetaData.isCommit;
        // if (
        //   String.isNotBlank(avalaraRequest.type) &&
        //   avalaraRequest.type.contains('Invoice')
        // ) {
        //   avalaraRequest.commit_Z = true;
        // }else{
        //   avalaraRequest.commit_Z = false;
        // }

        if (String.isNotBlank(taxRequest.taxMetaData.companyCode))
        {
            avalaraRequest.companyCode = taxRequest.taxMetaData.companyCode;
        }

        if (String.isNotBlank(taxRequest.taxMetaData.customerCode))
        {
            avalaraRequest.customerCode = taxRequest.taxMetaData.customerCode;
        }

        if (String.isNotBlank(taxRequest.customerTaxId))
        {
            avalaraRequest.businessIdentificationNo = taxRequest.customerTaxId;
        }

        if (String.isNotBlank(taxRequest.customerExemptionCode))
        {
            avalaraRequest.exemptionNo = taxRequest.customerExemptionCode;
        }

        if (String.isNotBlank(taxRequest.entityUseCode))
        {
            avalaraRequest.entityUseCode = taxRequest.entityUseCode;
        }

        avalaraRequest.date_Z = System.now() + '';
        //taxRequest.taxableCartItems = null;
        if (taxRequest.taxableCartItems != null &&  taxRequest.taxableCartItems.keySet().size() > 0 )
        {
            avalaraRequest.lines = prepareRequestFromExistingData(taxRequest, hasMultipleShipments);
        }
        else
        {
            avalaraRequest.lines = prepareRequestFromDB(taxRequest, hasMultipleShipments);
        }

        if (!hasMultipleShipments)
        {
            LwrCca_TaxAvalaraRequest.Addresses addresses = new LwrCca_TaxAvalaraRequest.Addresses();
            addresses.shipFrom = prepareShipFromAddress(taxRequest);
            addresses.shipTo = prepareShipToAddress(
                taxRequest.street,
                taxRequest.city,
                taxRequest.state,
                taxRequest.postalCode,
                taxRequest.country
            );
            avalaraRequest.addresses = addresses;
        }

        String avalaraRequestBody = JSON.serialize(avalaraRequest, true);
        avalaraRequestBody = avalaraRequestBody.replaceAll('_Z', '');
        callOutRequest.put(Constants.SERVICE_REQUEST_BODY, avalaraRequestBody);
        System.debug('====== avalaraRequest : '+avalaraRequestBody);
    }

    public virtual override LwrCca_TaxProviderResponse getTaxFromResponse( String strAvalaraResponseBody, LwrCca_TaxProviderRequest tpRequest)
    {
        LwrCca_TaxProviderResponse tpResponse = new LwrCca_TaxProviderResponse();
        Map<String, LwrCca_LineItemTaxDetails> taxes = new Map<String, LwrCca_LineItemTaxDetails>();
        Map<String, LwrCca_TaxableCartItem> taxableCartItems = tpRequest.taxableCartItems;

        LwrCca_TaxProviderResponse shippingResponse;
        System.debug('====== strAvalaraResponseBody : '+strAvalaraResponseBody);
        if (String.isNotBlank(strAvalaraResponseBody)) {
            LwrCca_TaxAvalaraResponse avalaraTaxResponse = LwrCca_TaxAvalaraResponse.parse(strAvalaraResponseBody);

            if ( avalaraTaxResponse.lines != null && avalaraTaxResponse.lines.size() > 0 )
            {
                for (LwrCca_TaxAvalaraResponse.Lines line : avalaraTaxResponse.lines)
                {
                    String lineNumber = line.lineNumber;
                    LwrCca_LineItemTaxDetails liTaxDetails = new LwrCca_LineItemTaxDetails();
                    liTaxDetails.tax = 0;
                    liTaxDetails.rate = 0;

                    if (line.tax > 0)
                    {
                            liTaxDetails.tax = line.tax;
                    }

                    if (line.taxableAmount > 0) {
                        liTaxDetails.rate = liTaxDetails.tax / line.taxableAmount;
                    }
                        if(!Test.isRunningTest()){
                            taxableCartItems.get(lineNumber).lineItemTexas.add(liTaxDetails);
                        }          
                }
                tpResponse.taxableCartItems = taxableCartItems;
            }
        }

        return tpResponse;
    }

    private List<LwrCca_TaxAvalaraRequest.Lines> prepareRequestFromExistingData(LwrCca_TaxProviderRequest taxRequest, Boolean hasMultipleShipments)
    {
        List<LwrCca_TaxAvalaraRequest.Lines> lines = new List<LwrCca_TaxAvalaraRequest.Lines>();

        for (String id : taxRequest.taxableCartItems.keySet())
        {
            LwrCca_TaxableCartItem cartItem = taxRequest.taxableCartItems.get(id);
            LwrCca_TaxAvalaraRequest.Lines line = prepareLine(
                id,
                cartItem.sku,
                cartItem.amount,
                cartItem.lineItemType,
                cartItem.taxClassId,
                cartItem.productExemptionCode,
                cartItem.entityUseCode,
                taxRequest,
                false
            );

            if (hasMultipleShipments)
            {
                LwrCca_TaxAvalaraRequest.Addresses addresses = new LwrCca_TaxAvalaraRequest.Addresses();
                addresses.shipFrom = prepareShipFromAddress(taxRequest);
                addresses.shipTo = prepareShipToAddress(
                cartItem.street,
                cartItem.city,
                cartItem.state,
                cartItem.postalCode,
                cartItem.country
                );
                line.addresses = addresses;
            }

            lines.add(line);
        }

        return lines;
    }

    private List<LwrCca_TaxAvalaraRequest.Lines> prepareRequestFromDB(LwrCca_TaxProviderRequest taxRequest, Boolean hasMultipleShipments)
    {

            String cartId = taxRequest.cartId;
            taxRequest.taxableCartItems = new Map<String, LwrCca_TaxableCartItem>();
            List<LwrCca_TaxAvalaraRequest.Lines> lines = new List<LwrCca_TaxAvalaraRequest.Lines>();
            String query = 'SELECT Id, Sku, TotalLineAmount, Quantity, Type,Product2Id,Name,Product2.Family, Product2.StockKeepingUnit';

            if (hasMultipleShipments)
            {
                query += ',CartDeliveryGroup.Id,CartDeliveryGroup.DeliverToStreet,CartDeliveryGroup.DeliverToCity,CartDeliveryGroup.DeliverToState,CartDeliveryGroup.DeliverToPostalCode,CartDeliveryGroup.DeliverToCountry';
            }

            if(taxRequest.taxMetaData.useProductTaxCodes)
            {
                query += ',Product2.Tax_Class_Id__c';
            }

            if(taxRequest.taxMetaData.productTaxExemption)
            {
                query += ',Product2.Taxable__c,Product2.Entity_Use_Code__c,Product2.Exemption_Code__c';
            }

            query += ' FROM CartItem WHERE  cartId=:cartId';

            if (!taxRequest.taxMetaData.shippingItemsTaxable)
            {
                query += ' AND Type = \'Product\'';
            }

            for (CartItem cartItem : Database.query(query))
            {
                LwrCca_TaxAvalaraRequest.Lines line = prepareLine(
                    cartItem.Id,
                    cartItem.SKU !=null ? cartItem.SKU : cartItem.Product2.StockKeepingUnit,
                    cartItem.TotalLineAmount,
                    cartItem.Type,
                    taxRequest.taxMetaData.useProductTaxCodes && cartItem.Product2.Tax_Class_Id__c !=null ? cartItem.Product2.Tax_Class_Id__c : null,
                    taxRequest.taxMetaData.productTaxExemption ? cartItem.Product2.Exemption_Code__c : null,
                    taxRequest.taxMetaData.productTaxExemption ? cartItem.Product2.Entity_Use_Code__c : null,
                    taxRequest,
                    true
                );

                if (hasMultipleShipments)
                {
                    LwrCca_TaxAvalaraRequest.Addresses addresses = new LwrCca_TaxAvalaraRequest.Addresses();
                    addresses.shipFrom = prepareShipFromAddress(taxRequest);
                    addresses.shipTo = prepareShipToAddress(
                    cartItem.CartDeliveryGroup.DeliverToStreet,
                    cartItem.CartDeliveryGroup.DeliverToCity,
                    cartItem.CartDeliveryGroup.DeliverToState,
                    cartItem.CartDeliveryGroup.DeliverToPostalCode,
                    cartItem.CartDeliveryGroup.DeliverToCountry
                    );
                    line.addresses = addresses;
                }

                lines.add(line);
            }

            return lines;
    }

    private LwrCca_TaxAvalaraRequest.Lines prepareLine(
        ID id,
        String sku,
        Decimal taxableAmount,
        String type,
        String taxClassId,
        String exemptionCode,
        String entityUseCode,
        LwrCca_TaxProviderRequest taxRequest,
        Boolean setInRequestToo
    )
    {
        LwrCca_TaxAvalaraRequest.Lines line = new LwrCca_TaxAvalaraRequest.Lines();
        line.number_Z = id;
        line.itemCode = sku;
        line.amount = taxableAmount;

        if (String.isNotBlank(taxRequest.taxMetaData.taxationPolicy))
        {
            line.taxIncluded = taxRequest.taxMetaData.taxationPolicy.equalsIgnoreCase( 'net' ) ? false : true;
        }

        line.taxCode = taxClassId;
        line.exemptionCode = exemptionCode;
        line.entityUseCode = entityUseCode;

        if (setInRequestToo)
        {
            LwrCca_TaxableCartItem tcItem = new LwrCca_TaxableCartItem();
            tcItem.id = id;
            tcItem.amount = taxableAmount;
            tcItem.sku = sku;
            tcItem.lineItemType = type;
            taxRequest.taxableCartItems.put(id, tcItem);
        }

        return line;
    }

    public override void prepareCommitTransaction(LwrCca_TaxProviderRequest taxRequest, Map<String, String> callOutRequest)
    {

    }

    LwrCca_TaxAvalaraRequest.ShipFrom prepareShipFromAddress(LwrCca_TaxProviderRequest taxRequest)
    {
        LwrCca_TaxAvalaraRequest.ShipFrom address = new LwrCca_TaxAvalaraRequest.ShipFrom();
        address.line1 = taxRequest.taxMetaData.shipFromLine1;
        address.city = taxRequest.taxMetaData.shipFromCity;
        address.region = taxRequest.taxMetaData.shipFromState;
        address.postalCode = taxRequest.taxMetaData.shipFromZipCode;
        address.country = taxRequest.taxMetaData.shipFromCountry;
        return address;
    }

    LwrCca_TaxAvalaraRequest.ShipFrom prepareShipToAddress(String street, String city, String state, String postalCode, String country)
    {
        LwrCca_TaxAvalaraRequest.ShipFrom address = new LwrCca_TaxAvalaraRequest.ShipFrom();
        address.line1 = street;
        address.city = city;
        address.region = state;
        address.postalCode = postalCode;
        address.country = country;
        return address;
    }
}