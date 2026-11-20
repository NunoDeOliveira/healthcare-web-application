using '../foundation/main.bicep'

//=================================================================
// Management Groups and identities
//=================================================================

param deployManagementGroup = false
param deployIdentities = false
param managementGroupName = 'mg-medicore'

//=================================================================
// Azure Policy
//=================================================================

param allowedLocations = [
  'spaincentral'
  'francecentral'
  'polandcentral'
  'italynorth'
  'austriaeast'
]

param policyEffect = 'Audit'

//=================================================================
// Cost Management
//=================================================================

param contactEmails = [
  'ndeoliveira.tlm@gmail.com'
  'ndeoliveriar@uoc.edu'
]

param startDate = '2026-11-01'
param endDate = '2027-11-01'
