@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code Root Entity'
@ObjectModel.sapObjectNodeType.name: 'ZMERP_COMP_CODE'
define root view entity ZMERP_R_COMPANY_CODE
  as select from zmerp_comp_code
  association [0..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [0..1] to I_Country  as _Country  on $projection.Country      = _Country.Country
{
  key company_code          as CompanyCode,
      company_name          as CompanyName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      @ObjectModel.foreignKey.association: '_Currency'
      currency_code         as CurrencyCode,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CountryVH', element: 'Country' }, useForValidation: true }]
      @ObjectModel.foreignKey.association: '_Country'
      country               as Country,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Currency,
      _Country
}
