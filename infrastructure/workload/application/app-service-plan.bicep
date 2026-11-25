param serverfarms_asp_medicore_app_name string = 'asp-medicore-app'
param location string = 'spaincentral'

resource serverfarms_asp_medicore_app_name_resource 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: serverfarms_asp_medicore_app_name
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
    asyncScalingEnabled: false
  }
}
