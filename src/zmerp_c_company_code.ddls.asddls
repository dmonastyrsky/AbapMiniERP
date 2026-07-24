@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code Projection View'
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'CompanyCode' ]
@Search.searchable: true

define root view entity ZMERP_C_COMPANY_CODE
  provider contract transactional_query
  as projection on ZMERP_R_COMPANY_CODE

{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key CompanyCode,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Search.ranking: #HIGH
      CompanyName,

      CurrencyCode,
      Country,

      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _Currency,
      _Country
}
