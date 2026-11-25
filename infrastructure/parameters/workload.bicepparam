using '../workload/main.bicep'

// MediCore workload deployment settings
param resourceGroupLocation = 'spaincentral'
param rgAppName = 'rg-medicore-app'
param rgNetworkName = 'rg-medicore-net'
param rgMonitorName = 'rg-medicore-monitor'

// Set true only once app-service-plan.bicep has been integrated into main.bicep.

param tagResourceGroup = {
  Project: 'p01-web'
  Environment: 'Lab'
  Owner: 'IT'
  CostCenter: 'IT-001'
}
