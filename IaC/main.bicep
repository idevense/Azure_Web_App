//set target scope.  Default is 'resourceGroup'
targetScope = 'subscription' 

//parameter definitions
param loc string  = 'norwayeast'
param pName string = ''
param sku string = 'F1'

var appName = pName // Fetch project name from package here
var rgName = 'rg-${appName}'
var aspName =  'asp-${appName}'

//Create a resource group for all the applications in the deployment
resource testAppResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: loc
}


//Create a network security group.  Since the scope below is set as "scope:bookAppResourceGroup", this gets created within the particular resource group
//by default, the resources are not allowed to be created under the subscription scope.  To be able to do that, your resource creation code should be designed as modules.
module testAppAsp 'aspModule.bicep' = {
  scope: testAppResourceGroup
  name: aspName
  params: {
    loc: loc
    aspName: aspName
    sku: sku
    instanceCount: 1
    isElasticScaling: true
    isZoneRedundant: false
    maxElasticWorkerCount: 2
  }
}

module testAppWebApp 'webappModule.bicep' = {
  scope: testAppResourceGroup
  name: appName
  params: {
    aspId: testAppAsp.outputs.aspId
    loc: loc
    webAppName: appName 
    frameworkVersion: 'v6.0'
  }
}
