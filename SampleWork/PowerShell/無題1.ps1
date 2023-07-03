# 実行する対象によって変える値
$SubscriptionId = "fd311764-61f2-43c7-8578-386dbd9785f0"
$ServicePrincipalName = "Terraform-Sample"
$TenantId = "4af6c951-81a2-4286-b6f3-4e1db39d5b1f"
$TerraformDirectory = "D:\Source\Git\Terraform-Sample"

If ($null -eq $env:ARM_SUBSCRIPTION_ID -or $null -eq $env:ARM_SUBSCRIPTION_ID -or $null -eq $env:ARM_TENANT_ID -or $null -eq $env:ARM_CLIENT_SECRET) {

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

    # サービスプリンシパルの作成または取得する。
    [System.Console]::WriteLine("")
    [System.Console]::WriteLine("-> Start service principal management.")
    Connect-AzAccount
    Get-AzContext
    Set-AzContext -Subscription $SubscriptionId

    ## サービスプリンシパルを取得する。
    [System.Console]::WriteLine("-> Get service principal.")
    $sp = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
    If ($null -eq $sp) {
        [System.Console]::WriteLine("-> Create service principal.")
        $sp = New-AzADServicePrincipal -DisplayName $ServicePrincipalName -Role "Contributor"
    }
    [System.Console]::WriteLine("-> Application id is " + $sp.AppId)
    [System.Console]::WriteLine("-> Application secret is " + $sp.PasswordCredentials.SecretText)

    ## サービスプリンシパルの内容を環境変数に保存する。
    $env:ARM_CLIENT_ID = $sp.AppId
    $env:ARM_SUBSCRIPTION_ID = $SubscriptionId
    $env:ARM_TENANT_ID = $TenantId
    $env:ARM_CLIENT_SECRET = $sp.PasswordCredentials.SecretText
}
## 環境変数を確認する。
[System.Console]::WriteLine("-> Display enviroment.")
Get-ChildItem env:ARM_*

Set-Location $TerraformDirectory

terraform init
[System.Console]::WriteLine("-> Initalized teraform.")

terraform fmt
[System.Console]::WriteLine("-> terraform fmt.")

$var1 = "ARM_CLIENT_ID=" + $sp.AppId
$var2 = "ARM_SUBSCRIPTION_ID=" + $SubscriptionId
$var3 = "ARM_TENANT_ID=" + $TenantId
$var4 = "ARM_CLIENT_SECRET=" + $sp.PasswordCredentials.SecretText
terraform plan -out main.tfplan -var $var1 -var $var2 -var $var3 -var $var4
[System.Console]::WriteLine("-> Created teraform plan.")

terraform apply main.tfplan
[System.Console]::WriteLine("-> Done teraform.")

