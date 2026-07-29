@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Value Help'
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP

define view entity ZMERP_I_ITEM_VH
  as select from ZMERP_R_ITEM
{
  @UI.lineItem: [{ position: 10, label: 'Item Code' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  key ItemCode,

  @UI.lineItem: [{ position: 20, label: 'Description' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  Description,

  @UI.lineItem: [{ position: 30, label: 'Item Type' }]
  ItemTypeCode, 

  @UI.lineItem: [{ position: 40, label: 'Item Group' }]
  ItemGroupCode,

  @UI.lineItem: [{ position: 50, label: 'Default VAT Code' }]
  DefaultVatCode
}
