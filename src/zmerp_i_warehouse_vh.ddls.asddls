@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Warehouse Value Help'
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP

define view entity ZMERP_I_WAREHOUSE_VH
  as select from ZMERP_R_WAREHOUSE
{
  @UI.lineItem: [{ position: 10, label: 'Warehouse Code' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  key WarehouseCode,

  @UI.lineItem: [{ position: 20, label: 'Warehouse Name' }]
  @Search.defaultSearchElement: true
  @Search.ranking: #HIGH
  @Search.fuzzinessThreshold: 0.7
  WarehouseName,

  @UI.lineItem: [{ position: 30, label: 'Company Code' }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMERP_I_COMPANY_CODE_VH', element: 'CompanyCode' } }]
  CompanyCode
}
