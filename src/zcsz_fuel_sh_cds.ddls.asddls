@AbapCatalog.sqlViewName: 'ZC_FUEL_VIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@VDM.viewType: #CONSUMPTION
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Search help for fuel for autos app'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType.dataClass: #CUSTOMIZING
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.supportedCapabilities
@Search.searchable: true
define view zcsz_fuel_sh_cds
  as select from zcsz_autos_db
  association [1..*] to zc_auto_cds as _auto on $projection.Fuel = _auto.fuel
{
       @Search.defaultSearchElement: true
       @UI.lineItem: [{ position: 10, label: 'Átugrottunk működik a navigálás' }]
  key  fuel as Fuel,
       _auto
}
group by fuel
