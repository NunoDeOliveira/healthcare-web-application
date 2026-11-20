//=================================================================
// MediCore Health - Tenant Deployment
//=================================================================

targetScope = 'tenant'

@description('Name of the management group')
param managementGroupName string


//=================================================================
// Management Groups
//=================================================================

module managementGroups './management-groups.bicep' = {
  name: 'medicore-management-groups'
  params: {
    managementGroupName: managementGroupName
  }
}
