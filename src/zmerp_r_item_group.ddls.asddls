@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Group Root Entity'
@ObjectModel.sapObjectNodeType.name: 'ZMERP_ITEM_GROUP'
define root view entity ZMERP_R_ITEM_GROUP
  as select from zmerp_item_group
  association [0..1] to ZMERP_R_VAT_RATE as _DefaultVATRate on $projection.DefaultVatCode = _DefaultVATRate.VatCode
{
  @ObjectModel.text.element: ['Description']
  key item_group_code            as ItemGroupCode,
      description           as Description,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZMERP_I_VAT_RATE_VH', element: 'VatCode' },
        useForValidation: true
      }]
      @ObjectModel.foreignKey.association: '_DefaultVATRate'
      default_vat_code      as DefaultVatCode,

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

      _DefaultVATRate
}
