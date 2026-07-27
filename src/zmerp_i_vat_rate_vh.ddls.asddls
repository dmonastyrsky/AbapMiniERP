@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VAT Rate Value Help'
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP

define view entity ZMERP_I_VAT_RATE_VH
  as select from ZMERP_R_VAT_RATE
{
  @UI.lineItem: [{ position: 10, label: 'VAT Code' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  key VatCode,

  @UI.lineItem: [{ position: 20, label: 'Description' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  Description,

  @UI.lineItem: [{ position: 30, label: 'Percentage (%)' }]
  Percentage
}
