//=================================================================
// MediCore Health - Azure Policies
//=================================================================

targetScope = 'subscription'

@description('Allowed Azure regions')
param allowedLocations array

@description('Policy effect')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param policyEffect string = 'Audit'

@description('Policy assignment name')
param policyAssignmentName string = 'medicore-allowed-loc'

//=================================================================
// Allowed Locations
//=================================================================

resource allowedLocationsPolicy 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: policyAssignmentName
  properties: {
    displayName: 'MediCore - Allowed Locations'
    description: 'Restrict Azure resources to approved regions'
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
      effect: {
        value: policyEffect
      }
    }
  }
}

output policyAssignmentId string = allowedLocationsPolicy.id
