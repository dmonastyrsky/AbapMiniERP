@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Root Entity'
@ObjectModel.sapObjectNodeType.name: 'ZMERP_ITEM'
define root view entity ZMERP_R_ITEM
  as select from zmerp_item
  association [0..1] to ZMERP_R_ITEM_GROUP as _ItemGroup      on $projection.ItemGroupCode = _ItemGroup.ItemGroupCode
  association [0..1] to ZMERP_R_VAT_RATE   as _DefaultVATRate on $projection.DefaultVatCode = _DefaultVATRate.VatCode
  association [0..1] to ZMERP_I_ITEM_TYPE_VH as _ItemType       on $projection.ItemTypeCode = _ItemType.ItemTypeCode
{
  @ObjectModel.text.element: ['Description']
  key item_code             as ItemCode,
      description           as Description,
      
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZMERP_I_ITEM_TYPE_VH', element: 'ItemTypeCode' },
        useForValidation: true
      }]
      @ObjectModel.text.association: '_ItemType'      
      item_type             as ItemTypeCode, 

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZMERP_I_ITEM_GROUP_VH', element: 'ItemGroupCode' },
        useForValidation: true
      }]
      @ObjectModel.foreignKey.association: '_ItemGroup'
      item_group_code       as ItemGroupCode,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZMERP_I_VAT_RATE_VH', element: 'VatCode' },
        useForValidation: true
      }]
      @ObjectModel.foreignKey.association: '_DefaultVATRate'
      @ObjectModel.text.association: '_DefaultVATRate'
      default_vat_code      as DefaultVatCode,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'I_UnitOfMeasureStdVH', element: 'UnitOfMeasure' },
        useForValidation: true
      }]
      base_unit_of_measure  as BaseUnitOfMeasure,

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

      _ItemGroup,
      _DefaultVATRate,
      _ItemType
}
