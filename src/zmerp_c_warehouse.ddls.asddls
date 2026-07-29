@EndUserText.label: 'Warehouse Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'WarehouseCode' ]
@Search.searchable: true
define root view entity ZMERP_C_WAREHOUSE
  provider contract transactional_query
  as projection on ZMERP_R_WAREHOUSE
{
      @ObjectModel.text.element: ['WarehouseName']
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      key WarehouseCode,

      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      WarehouseName,

      CompanyCode,

      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _CompanyCode : redirected to ZMERP_C_COMPANY_CODE
}
