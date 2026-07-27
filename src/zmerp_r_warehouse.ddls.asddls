@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Warehouse Root Entity'
@ObjectModel.sapObjectNodeType.name: 'ZMERP_WAREHOUSE'
define root view entity ZMERP_R_WAREHOUSE
  as select from zmerp_warehouse
  association [0..1] to ZMERP_R_COMPANY_CODE as _CompanyCode on $projection.CompanyCode = _CompanyCode.CompanyCode
{
  key warehouse_code        as WarehouseCode,
      warehouse_name        as WarehouseName,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZMERP_I_COMPANY_CODE_VH', element: 'CompanyCode' }, useForValidation: true }]
      @ObjectModel.foreignKey.association: '_CompanyCode'
      company_code          as CompanyCode,

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

      _CompanyCode
}
