@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZMERP_PO_HDR'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZMERP_C_PURCHASEORDER
  provider contract TRANSACTIONAL_QUERY
  as projection on ZMERP_R_PURCHASEORDER
  association [1..1] to ZMERP_R_PURCHASEORDER as _BaseEntity on $projection.DOCUMENTUUID = _BaseEntity.DOCUMENTUUID
{
  key DocumentUUID,
  DocumentNumber,
  DocumentDate,
  PostingDate,
  CompanyCode,
  WarehouseCode,
  BusinessPartner,
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
  TotalNetAmount,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  TotalGrossAmount,
  @Semantics: {
    User.Createdby: true
  }
  ResponsiblePerson,
  Remarks,
  SupplierReference,
  DeliveryDate,
  Status,
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
