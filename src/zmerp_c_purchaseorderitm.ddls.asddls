@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZMERP_PO_ITM'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZMERP_C_PURCHASEORDERITM
  provider contract TRANSACTIONAL_QUERY
  as projection on ZMERP_R_PURCHASEORDERITM
  association [1..1] to ZMERP_R_PURCHASEORDERITM as _BaseEntity on $projection.ITEMUUID = _BaseEntity.ITEMUUID
{
  key ItemUUID,
  HeaderUUID,
  ItemNo,
  ItemCode,
  @Semantics: {
    Quantity.Unitofmeasure: 'UnitOfMeasure'
  }
  Quantity,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'UnitOfMeasure', 
      Entity.Name: 'I_UnitOfMeasureStdVH', 
      Useforvalidation: true
    } ]
  }
  UnitOfMeasure,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'Currency', 
      Entity.Name: 'I_CurrencyStdVH', 
      Useforvalidation: true
    } ]
  }
  Currency,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  Price,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  NetAmount,
  VatCode,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  VatAmount,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  GrossAmount,
  DeliveryCompleted,
  @Semantics: {
    User.Createdby: true
  }
  CreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  CreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  _BaseEntity
}
