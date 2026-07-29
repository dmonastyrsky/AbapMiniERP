@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Group Value Help'
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP

define view entity ZMERP_I_ITEM_GROUP_VH
  as select from ZMERP_R_ITEM_GROUP
{
  @UI.lineItem: [{ position: 10, label: 'Item Group' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  key ItemGroupCode,

  @UI.lineItem: [{ position: 20, label: 'Description' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  Description,

  @UI.lineItem: [{ position: 30, label: 'Default VAT Code' }]
  @UI.textArrangement: #TEXT_ONLY
  @ObjectModel.text.element: ['DefaultVatDescription']  
  DefaultVatCode,
  
  @UI.hidden: true
  _DefaultVATRate.Description as DefaultVatDescription,  
  
  _DefaultVATRate
}
