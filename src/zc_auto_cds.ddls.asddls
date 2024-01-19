@AbapCatalog.sqlViewName: 'ZC_AUTO_VIEW'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Auto cds view'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType.dataClass: #CUSTOMIZING
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S
@ObjectModel.supportedCapabilities
@Search.searchable: true
define root view zc_auto_cds
  as select from zcsz_autos_db
  association [1..*] to zcsz_fuel_sh_cds as _fuel_sh on $projection.fuel = _fuel_sh.Fuel
{
      @UI.facet: [

        {
          label: 'General Information',
          id: 'GeneralInfo',
          type: #COLLECTION,
          position: 10
        },
        {
          label: 'General',
          id: 'Travel',
          type: #IDENTIFICATION_REFERENCE,
          purpose: #STANDARD,
          parentId: 'GeneralInfo',
          position: 10
        }
      ]
      @UI.identification: [{ position: 10 }  ]
      key car_id,
      @UI.lineItem: [{ position: 20, label: 'Üzemanyag' }]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Fuel'
      @Consumption.valueHelpDefinition: [{ entity.element: 'fuel' , entity.name: 'zcsz_fuel_sh_cds', label: 'Üzemanyag' }]
      @UI.identification: [{ position: 20 }   ]
      @UI.selectionField: [{ position: 20 }]
      fuel,
      @UI.identification: [{ position: 30 } ]
      @UI.lineItem: [{ position: 30, label: 'Foglalás kezdete' }]
      date_from,
      @UI.identification: [{ position: 40 } ]
      @UI.lineItem: [{ position: 40, label: 'Foglalás vége' }]
      date_to,
      @UI.identification: [{ position: 50 } ]
      @Search.defaultSearchElement: true
      @UI.lineItem: [{ position: 50, label: 'Ülések száma' }]
      numseats,
      @UI.lineItem: [ { type: #FOR_ACTION, dataAction: 'customerDisplay', label: 'Foglalás' , position: 50 }]
      _fuel_sh
}
