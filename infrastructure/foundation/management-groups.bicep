//=================================================================
// MediCore Health - Management Groups
//=================================================================

targetScope = 'tenant'

@description('Management group name')
param managementGroupName string = 'mg-medicore'

resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: managementGroupName
  properties: {
    displayName: 'MediCore Health'
  }
}

output managementGroupId string = managementGroup.id
