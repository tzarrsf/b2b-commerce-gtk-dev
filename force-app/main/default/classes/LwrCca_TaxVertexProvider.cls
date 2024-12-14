/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-14-2024
 * @last modified by  : Tom Zarr
**/
public without sharing class LwrCca_TaxVertexProvider extends LwrCca_TaxAbstractProvider {
  public LwrCca_TaxVertexProvider() {
  }

  public override void prepareCreateTransaction(
    LwrCca_TaxProviderRequest taxRequest,
    Map<String, String> callOutRequest
  ) {
    Boolean hasMultipleShipments = taxRequest.hasMultipleShipments != null &&
      taxRequest.hasMultipleShipments == true ? true : false;

    
    LwrCca_TaxVertexRequest vertexRequest = new LwrCca_TaxVertexRequest();
    vertexRequest.transactionType = taxRequest.taxMetaData.transactionType;
    vertexRequest.saleMessageType = taxRequest.taxMetaData.documentType;

    //setting currency 
    LwrCca_TaxVertexRequest.cls_currency currencyZ = new LwrCca_TaxVertexRequest.cls_currency();
    currencyZ.isoCurrencyCodeAlpha = taxRequest.currencyCode;
    vertexRequest.currency_z = currencyZ;

   // setting current date 
   DateTime todaysDate = System.today();
   String todaysDateStr = todaysDate.format('yyyy-MM-dd');
   vertexRequest.documentDate = todaysDateStr;
   vertexRequest.taxPointDate = todaysDateStr;
   
   vertexRequest.documentNumber = String.isNotBlank(taxRequest.cartId) ? taxRequest.cartId : taxRequest.orderNo;
   vertexRequest.transactionId = String.isNotBlank(taxRequest.cartId) ? taxRequest.cartId : taxRequest.orderNo;
    if ( taxRequest.taxableCartItems != null && taxRequest.taxableCartItems.keySet().size() > 0
    ) {
     vertexRequest.lineItems = prepareRequestFromExistingData(
        taxRequest,
        hasMultipleShipments
      );
    } else {
     vertexRequest.lineItems = prepareRequestFromDB(
        taxRequest,
        hasMultipleShipments
      );
    }

    //in case there is single shipment , setting addresses at transaction level 
    if (!hasMultipleShipments) {
      vertexRequest.customer = setCustomerDetails(
        taxRequest,
        taxRequest.street,
        taxRequest.city,
        taxRequest.state,
        taxRequest.postalCode,
        taxRequest.country
      );
      vertexRequest.seller = setSellerDetails(taxRequest);
    }
    
    String vertexRequestBody = JSON.serialize(vertexRequest, true);
    vertexRequestBody = vertexRequestBody.replaceAll('_z', '');
    callOutRequest.put(Constants.SERVICE_REQUEST_BODY, vertexRequestBody);
    System.debug('====== vertexRequest : '+vertexRequestBody);
  }

  public virtual override LwrCca_TaxProviderResponse getTaxFromResponse(
    String strvertexResponseBody,
    LwrCca_TaxProviderRequest tpRequest
  ) {
    LwrCca_TaxProviderResponse tpResponse = new LwrCca_TaxProviderResponse();
    Map<String, LwrCca_LineItemTaxDetails> taxes = new Map<String, LwrCca_LineItemTaxDetails>();
    Map<String, LwrCca_TaxableCartItem> taxableCartItems = tpRequest.taxableCartItems;

    LwrCca_TaxProviderResponse shippingResponse;
    System.debug('====== strvertexResponseBody : '+strvertexResponseBody);
    if (String.isNotBlank(strvertexResponseBody)) {
      LwrCca_TaxVertexResponse vertexTaxResponse = LwrCca_TaxVertexResponse.parse(
        strVertexResponseBody
      );
      if (
        vertexTaxResponse.data.lineItems != null && vertexTaxResponse.data.lineItems.size() > 0
      ) {
        for (LwrCca_TaxVertexResponse.cls_lineItems line : vertexTaxResponse.data.lineItems) {
          String lineItemId = line.lineItemId;
          LwrCca_LineItemTaxDetails liTaxDetails = new LwrCca_LineItemTaxDetails();
          liTaxDetails.tax = 0;
          liTaxDetails.rate = 0;
          if (line.totalTax > 0) {
            liTaxDetails.tax = line.totalTax;
          }
          if (line.fairMarketValue > 0) {
            liTaxDetails.rate = liTaxDetails.tax / line.fairMarketValue;
          }
          taxableCartItems.get(lineItemId).lineItemTexas.add(liTaxDetails);
        }
        tpResponse.taxableCartItems = taxableCartItems;
      }
    }
    return tpResponse;
  }

  private List<LwrCca_TaxVertexRequest.cls_lineItems> prepareRequestFromExistingData(
    LwrCca_TaxProviderRequest taxRequest,
    Boolean hasMultipleShipments
  ) {
    List<LwrCca_TaxVertexRequest.cls_lineItems> lines = new List<LwrCca_TaxVertexRequest.cls_lineItems>();
    for (String id : taxRequest.taxableCartItems.keySet()) {
      LwrCca_TaxableCartItem cartItem = taxRequest.taxableCartItems.get(id);
      LwrCca_TaxVertexRequest.cls_lineItems line = prepareLine(
        id,
        cartItem.sku,
        cartItem.amount,
        cartItem.lineItemType,
        cartItem.quantity,
        cartItem.taxClassId,
        cartItem.productExemptionCode,
        cartItem.entityUseCode,
        taxRequest,
        false
      );
     
      if (hasMultipleShipments) {
        line.seller = setSellerDetails(taxRequest);
        line.customer = setCustomerDetails(
          taxRequest,
          cartItem.street,
          cartItem.city,
          cartItem.state,
          cartItem.postalCode,
          cartItem.country
        );
      }
      lines.add(line);
    }
    return lines;
  }

  private List<LwrCca_TaxVertexRequest.cls_lineItems> prepareRequestFromDB(
    LwrCca_TaxProviderRequest taxRequest,
    Boolean hasMultipleShipments
  ) {
   
    String cartId = taxRequest.cartId;
    taxRequest.taxableCartItems = new Map<String, LwrCca_TaxableCartItem>();
    List<LwrCca_TaxVertexRequest.cls_lineItems> lines = new List<LwrCca_TaxVertexRequest.cls_lineItems>();
    String query = 'SELECT Id, Sku, TotalLineAmount, Quantity, Type,Product2Id,Name,Product2.Family, Product2.StockKeepingUnit';
    if (hasMultipleShipments) {
      query += ',CartDeliveryGroup.Id,CartDeliveryGroup.DeliverToStreet,CartDeliveryGroup.DeliverToCity,CartDeliveryGroup.DeliverToState,CartDeliveryGroup.DeliverToPostalCode,CartDeliveryGroup.DeliverToCountry';
    }
    if(taxRequest.taxMetaData.useProductTaxCodes){
      query += ',Product2.Tax_Class_Id__c';
    }
    if(taxRequest.taxMetaData.productTaxExemption){
      query += ',Product2.Taxable__c,Product2.Entity_Use_Code__c,Product2.Exemption_Code__c';
    }
    query += ' FROM CartItem WHERE  cartId=:cartId';
    if (!taxRequest.taxMetaData.shippingItemsTaxable) {
      query += ' AND Type = \'Product\'';
    }
    for (CartItem cartItem : Database.query(query)) {
      LwrCca_TaxVertexRequest.cls_lineItems line = prepareLine(
        cartItem.Id,
        cartItem.SKU !=null ? cartItem.SKU : cartItem.Product2.StockKeepingUnit,
        cartItem.TotalLineAmount,
        cartItem.Type,
        cartItem.Quantity,
        taxRequest.taxMetaData.useProductTaxCodes && cartItem.Product2.Tax_Class_Id__c !=null ? cartItem.Product2.Tax_Class_Id__c : null,
        taxRequest.taxMetaData.productTaxExemption ? cartItem.Product2.Exemption_Code__c : null,
        taxRequest.taxMetaData.productTaxExemption ? cartItem.Product2.Entity_Use_Code__c : null,
        taxRequest,
        true
      );
      if (hasMultipleShipments) {
        line.seller = setSellerDetails(taxRequest);
        line.customer = setCustomerDetails(
          taxRequest,
          cartItem.CartDeliveryGroup.DeliverToStreet,
          cartItem.CartDeliveryGroup.DeliverToCity,
          cartItem.CartDeliveryGroup.DeliverToState,
          cartItem.CartDeliveryGroup.DeliverToPostalCode,
          cartItem.CartDeliveryGroup.DeliverToCountry
        );
      }
      lines.add(line);
    }
    return lines;
  }

  private LwrCca_TaxVertexRequest.cls_lineItems prepareLine(
    ID id,
    String sku,
    Decimal taxableAmount,
    String type,
    Decimal quantity,
    String taxClassId,
    String exemptionCode,
    String entityUseCode,
    LwrCca_TaxProviderRequest taxRequest,
    Boolean setInRequestToo
  ) {
    LwrCca_TaxVertexRequest.cls_lineItems line = new LwrCca_TaxVertexRequest.cls_lineItems();
    line.lineItemId = id;
    line.extendedPrice = taxableAmount;
    line.fairMarketValue = taxableAmount;
    line.usage = type;
    LwrCca_TaxVertexRequest.cls_product product = new LwrCca_TaxVertexRequest.cls_product();
    product.value = sku;
    line.product = product;
    LwrCca_TaxVertexRequest.cls_quantity prdQuantity = new LwrCca_TaxVertexRequest.cls_quantity();
    prdQuantity.value = quantity;
    line.quantity = prdQuantity;
    if (setInRequestToo) {
      LwrCca_TaxableCartItem tcItem = new LwrCca_TaxableCartItem();
      tcItem.id = id;
      tcItem.amount = taxableAmount;
      tcItem.sku = sku;
      tcItem.lineItemType = type;
      taxRequest.taxableCartItems.put(id, tcItem);
    }

    return line;
  }

  public override void prepareCommitTransaction(LwrCca_TaxProviderRequest taxRequest, Map<String, String> callOutRequest) {

  }
  LwrCca_TaxVertexRequest.cls_seller setSellerDetails(
    LwrCca_TaxProviderRequest taxRequest
  ) {
    LwrCca_TaxVertexRequest.cls_seller seller = new LwrCca_TaxVertexRequest.cls_seller();
    LwrCca_TaxVertexRequest.cls_physicalOrigin origin = new LwrCca_TaxVertexRequest.cls_physicalOrigin();
    origin.streetAddress1 = taxRequest.taxMetaData.shipFromLine1;
    origin.city = taxRequest.taxMetaData.shipFromCity;
    origin.mainDivision = taxRequest.taxMetaData.shipFromState;
    origin.postalCode = taxRequest.taxMetaData.shipFromZipCode;
    origin.country = taxRequest.taxMetaData.shipFromCountry;
    if (String.isNotBlank(taxRequest.taxMetaData.companyCode)) {
      seller.company = taxRequest.taxMetaData.companyCode;
     }
    seller.physicalOrigin = origin;
    return seller;
  }

  LwrCca_TaxVertexRequest.cls_customer setCustomerDetails(
    LwrCca_TaxProviderRequest taxRequest,
    String street,
    String city,
    String state,
    String postalCode,
    String country
  ) {
    LwrCca_TaxVertexRequest.cls_customer customer = new LwrCca_TaxVertexRequest.cls_customer();
    LwrCca_TaxVertexRequest.cls_customerCode customerCd = new LwrCca_TaxVertexRequest.cls_customerCode();
     if (String.isNotBlank( taxRequest.taxMetaData.customerCode)) {
      customerCd.classCode =   taxRequest.taxMetaData.customerCode;
      customerCd.isBusinessIndicator = true; 
      customerCd.value =  taxRequest.taxMetaData.customerCode;
      customer.customerCode = customerCd;
     }

     if (taxRequest.taxMetaData.customerTaxExemption){
      if (String.isNotBlank(taxRequest.customerExemptionCode)) {
        LwrCca_TaxVertexRequest.cls_exemptionCertificate exemptionCertificate = new LwrCca_TaxVertexRequest.cls_exemptionCertificate();
        exemptionCertificate.exemptionCertificateNumber = taxRequest.customerExemptionCode;
        exemptionCertificate.value = taxRequest.customerExemptionCode;
        customer.exemptionCertificate = exemptionCertificate;
        
      }else{
        customer.isTaxExempt = true;
      }
      if (String.isNotBlank(taxRequest.entityUseCode)) {
        customer.exemptionReasonCode = taxRequest.entityUseCode;
       }
     }
		LwrCca_TaxVertexRequest.cls_destination destination = new LwrCca_TaxVertexRequest.cls_destination();
    destination.streetAddress1 = street;
    destination.city = city;
    destination.mainDivision = state;
    destination.postalCode = postalCode;
    destination.country = country;

    
    customer.destination = destination;
    return customer;
  }
}