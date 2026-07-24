@EndUserText.label: 'Warehouse Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZMERP_C_WAREHOUSE
  provider contract transactional_query
  as projection on ZMERP_R_WAREHOUSE
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      key WarehouseCode,

      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.7
      WarehouseName,

      @ObjectModel.text.element: ['CompanyName']
      CompanyCode,

      @EndUserText.label: 'Company Name'
      @Search.defaultSearchElement: true
      @Search.ranking: #MEDIUM
      _CompanyCode.CompanyName as CompanyName,

      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _CompanyCode : redirected to ZMERP_C_COMPANY_CODE
}
