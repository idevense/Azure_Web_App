//module to create web app

param webAppName string
param aspId string
param loc string
param frameworkVersion string = 'v6.0'

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: loc
  kind: 'app'

  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webAppName}.azurewebsites.net'
        sslState: 'SniEnabled' //not supported in SKU F1
        hostType: 'Standard'
      }
    ]
    
    serverFarmId: aspId
    reserved: false
    hyperV: false

    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true //not supported in SKU F1
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }

    clientAffinityEnabled: true
    clientCertEnabled: true //not supporteds in SKU F1
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize:  0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }

}

resource siteConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webApp
  name: 'web'
  //location: loc
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'default.htm'
      'default.html'
      'default.asp'
      'default.aspx'
      'index.htm'
      'index.html'
    ]
    netFrameworkVersion: frameworkVersion
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2022'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 50
    detailedErrorLoggingEnabled: false
    publishingUsername: '$${webAppName}'
    scmType: 'BitbucketGit' //https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.management.appservice.fluent.models.scmtype?view=azure-dotnet
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false //not supporteds in SKU F1
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled:  false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 1
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'Disabled'
    preWarmedInstanceCount: 0
    minimumElasticInstanceCount: 1
    functionsRuntimeScaleMonitoringEnabled: false
    azureStorageAccounts: {}
  }
}

resource siteHostNameBinding 'Microsoft.Web/sites/hostNameBindings@2022-09-01'  = {
  parent: webApp
  name: '${webAppName}.azurewebsites.net'
  //location: loc
  properties: {
    siteName: webAppName
    hostNameType: 'Verified'
  }
}

output siteId string = webApp.id
