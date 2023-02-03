# 実行する対象によって変える値
$SubscriptionId = "fd311764-61f2-43c7-8578-386dbd9785f0"
$ServicePrincipalName = "Terraform-Sample"
$TenantId = "4af6c951-81a2-4286-b6f3-4e1db39d5b1f"


# Terraform がインストールされていることを確認する。
[System.Console]::WriteLine("")
[System.Console]::WriteLine("-> Check terraform installed.")
$version = terraform -version
if ($version -eq '')
{
    return
}
[System.Console]::WriteLine("-> Terraform Version is" + $version)

# Azure にサインインする。
[System.Console]::WriteLine("")
[System.Console]::WriteLine("-> Singin to azure.")
az login
az account show
az account list --query "[?user.name=='yo-mukaida@kentem.co.jp'].{Name:name, ID:id, Default:isDefault}" --output Table

# サービス プリンシパルの作成または取得する。
[System.Console]::WriteLine("")
[System.Console]::WriteLine("-> Create service principal.")
Connect-AzAccount
Get-AzContext
Set-AzContext -Subscription $SubscriptionId

$sp = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
If ( $null -eq $sp) {
    $sp = New-AzADServicePrincipal -DisplayName $ServicePrincipalName -Role "Contributor"
}
[System.Console]::WriteLine("-> Application id is " + $sp.AppId)
[System.Console]::WriteLine("-> Application secret is " + $sp.PasswordCredentials.SecretText)

$env:ARM_CLIENT_ID = $sp.AppId
$env:ARM_SUBSCRIPTION_ID = $SubscriptionId
$env:ARM_TENANT_ID = $TenantId
$env:ARM_CLIENT_SECRET = $sp.PasswordCredentials.SecretText