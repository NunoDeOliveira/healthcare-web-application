//=================================================================
// MediCore Health - Foundation Deployment
//=================================================================

targetScope = 'subscription'

@description('Deploy Management Groups')
param deployManagementGroup bool = false

@description('Deploy Microsoft Entra security groups')
param deployIdentities bool = false

@description('Management Group name')
param managementGroupName string = 'mg-medicore'

@description('Budget notification email addresses')
param contactEmails array

@description('Budget start date')
param startDate string

@description('Budget end date')
param endDate string

@description('Allowed Azure regions')
param allowedLocations array = [
  'spaincentral'
  'francecentral'
  'polandcentral'
  'italynorth'
  'austriaeast'
]

@description('Azure Policy effect')
@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param policyEffect string = 'Audit'

//=================================================================
// Management Groups
//=================================================================

module tenantDeployment './tenant.bicep' = if (deployManagementGroup) {
  name: 'medicore-tenant'
  scope: tenant()
  params: {
    managementGroupName: managementGroupName
  }
}

//=================================================================
// Microsoft Entra ID
//=================================================================

module identities './identities.bicep' = if (deployIdentities) {
  name: 'medicore-identities'
}

//=================================================================
// Azure RBAC
//=================================================================

module rbac './rbac.bicep' = {
  name: 'medicore-rbac'
}

//=================================================================
// Azure Policy
//=================================================================

module policies './policies.bicep' = {
  name: 'medicore-policies'
  params: {
    allowedLocations: allowedLocations
    policyEffect: policyEffect
  }
}

//=================================================================
// Cost Management
//=================================================================

module budgets './budgets.bicep' = {
  name: 'medicore-budgets'
  params: {
    contactEmails: contactEmails
    startDate: startDate
    endDate: endDate
  }
}
