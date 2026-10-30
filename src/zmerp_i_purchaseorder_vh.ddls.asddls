@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Value Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity ZMERP_I_PURCHASEORDER_VH
  as select from ZMERP_R_PURCHASEORDER
{
      @UI.hidden: true
  key DocumentUUID,

      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
  key DocumentNumber,

      @Search.defaultSearchElement: true
      CompanyCode,

      @Search.defaultSearchElement: true
      WarehouseCode,

      @Search.defaultSearchElement: true
      BusinessPartnerCode,

      @ObjectModel.text.element: [ 'StatusDescription' ]
      @UI.textArrangement: #TEXT_ONLY
      Status,
      _Status.Description as StatusDescription,

      CurrencyCode,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalNetAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalGrossAmount
}
where
  Status <> 'X'
