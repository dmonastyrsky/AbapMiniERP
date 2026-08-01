@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code Projection View'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'CompanyCode' ]
@Search.searchable: true

define root view entity ZMERP_C_COMPANY_CODE
  provider contract transactional_query
  as projection on ZMERP_R_COMPANY_CODE
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @ObjectModel.text.element: ['CompanyName']
  key CompanyCode,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      @Search.ranking: #HIGH
      CompanyName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CountryVH', element: 'Country' }, useForValidation: true }]
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
