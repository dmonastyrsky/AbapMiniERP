@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Company Code Usage Dependencies'
@VDM.viewType: #COMPOSITE
define view entity ZMERP_I_COMPANY_CODE_USAGE
  as select from ZMERP_R_WAREHOUSE
{
  key CompanyCode,
      'Warehouse' as UsedInEntity
}
// union all select from ZMERP_R_PurchaseOrder
// {
//   key CompanyCode,
//       'Purchase Order' as UsedInEntity
// }
// union all select from ZMERP_R_SalesOrder
// {
//   key CompanyCode,
//       'Sales Order' as UsedInEntity
// }
