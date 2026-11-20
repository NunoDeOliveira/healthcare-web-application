using '../workload/main.bicep'

//=================================================================
// MediCore Health - Workload Parameters
//=================================================================

param resourceGroupLocation = 'spaincentral'

param resourceGroupNames = [
  'rg-medicore-app'
  'rg-medicore-net'
  'rg-medicore-monitor'
]

param tagResourceGroup = {
  Project: 'p01-web'
  Environment: 'Lab'
  Owner: 'IT'
  CostCenter: 'IT-001'
}
