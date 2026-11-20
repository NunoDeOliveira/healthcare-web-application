//===================================================================
//             Create a budget
//===================================================================

targetScope = 'subscription'

@description('Name of the Budget. It should be unique within a resource group.')
param budgetName string = 'budget-medicore-p01'

@description('The total amount of cost or usage to track with the budget')
param amount int = 14

@description('The time covered by a budget. Tracking of the amount will be reset based on the time grain.')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param timeGrain string = 'Monthly'

@description('The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. Past start date should be selected within the timegrain preiod.')
param startDate string = '2026-11-01'

@description('The end date for the budget in YYYY-MM-DD format. If not provided, we default this to 10 years from the start date.')
param endDate string = '2027-11-01'

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param firstThreshold int = 50

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param secondThreshold int = 80

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param thirdThreshold int = 100

@description('The list of email addresses to send the budget notification to when the threshold is exceeded.')
param contactEmails array 

@description('The set of values for the resource group filter.')
param resourceGroupFilterValues array = [
  'rg-medicore-app'
  'rg-medicore-net'
  'rg-medicore-monitor'
]

resource budget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: budgetName
  properties: {
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    timeGrain: timeGrain
    amount: amount
    category: 'Cost'
    notifications: {
      NotificationForExceededBudget1: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: firstThreshold
        contactEmails: contactEmails
      }
      NotificationForExceededBudget2: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: secondThreshold
        contactEmails: contactEmails
      }
      NotificationForExceededBudget3: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: thirdThreshold
        contactEmails: contactEmails
      }
    }
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: resourceGroupFilterValues
      }
    }
  }
}
