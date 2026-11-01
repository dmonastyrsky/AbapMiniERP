@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Value Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

define view entity ZMERP_I_PO_VH
  as select from ZMERP_R_PURCHASEORDER
{
      @UI.hidden: true
  key DocumentUUID,

      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      @UI.lineItem: [{ position: 10, importance: #HIGH }]
  key DocumentNumber,

      @ObjectModel.text.element: [ 'CompanyName' ]
      @UI.textArrangement: #TEXT_FIRST
      @UI.lineItem: [{ position: 20 }]
      CompanyCode,     
      _CompanyCode.CompanyName as CompanyName,

      @ObjectModel.text.element: [ 'WarehouseName' ]
      @UI.textArrangement: #TEXT_FIRST
      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 30 }]
      WarehouseCode,
      _Warehouse.WarehouseName as WarehouseName,
      
      @ObjectModel.text.element: [ 'PartnerName' ]
      @UI.textArrangement: #TEXT_FIRST
      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 40 }]
      BusinessPartnerCode,
      _BusinessPartner.PartnerName as PartnerName,

      @ObjectModel.text.element: [ 'StatusDescription' ]
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{ position: 50 }]
      Status,
      _Status.Description as StatusDescription,

      CurrencyCode,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem: [{ position: 60 }]
      TotalNetAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem: [{ position: 70 }]
      TotalGrossAmount
}
where
  Status <> 'X'
