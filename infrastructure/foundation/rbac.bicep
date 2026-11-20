//=================================================================
// Create roles and permissions for grups and users
//=================================================================

targetScope = 'subscription'

@description('Array of actions for the roleDefinition')
param actions array = [
  'Microsoft.Resources/subscriptions/resourceGroups/read'
]

@description('Array of notActions for the roleDefinition')
param notActions array = []

@description('Name of the custom role')
param roleName string = 'MediCore - Resource Group Reader'

@description('Allows reading resource group information')
param roleDescription string = 'Read-only access to Azure resource group information'

var roleDefName = guid(roleName)

resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: roleDefName
  properties: {
    roleName: roleName
    description: roleDescription
    type: 'customRole'
    permissions: [
      {
        actions: actions
        notActions: notActions
      }
    ]
    assignableScopes: [
      subscription().id
    ]
  }
}







