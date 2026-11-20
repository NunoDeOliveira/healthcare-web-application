//===================================================================
//       Create identities of Microsoft Entra ID of MediCore.
//===================================================================

targetScope = 'subscription'

extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

@description('Microsoft Entra security groups')
param groupNames array = [
  'grp-owners'
  'grp-admins'
  'grp-devs'
  'grp-clinic'
]

//=================================================================
// Create security groups
//=================================================================

resource groups 'Microsoft.Graph/groups@v1.0' = [
  for groupName in groupNames: {
    uniqueName: 'medicore-${groupName}'
    displayName: groupName
    mailEnabled: false
    mailNickname: groupName
    securityEnabled: true
  }
]

output groupIds array = [
  for (groupName, i) in groupNames: {
    name: groupName
    id: groups[i].id
  }
]




