@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code Value Help'
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP
//@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZMERP_I_COMPANY_CODE_VH
  as select from ZMERP_R_COMPANY_CODE
{
  @UI.lineItem: [{ position: 10, label: 'Company Code' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  key CompanyCode,

  @UI.lineItem: [{ position: 20, label: 'Company Name' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  CompanyName,

  @UI.lineItem: [{ position: 30, label: 'Currency' }]
  CurrencyCode,

  @UI.lineItem: [{ position: 40, label: 'Country' }]
  Country
}
