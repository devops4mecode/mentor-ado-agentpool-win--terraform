# Create Self-Hosted Azure DevOps Agent Pool

## Prerequisites:
- Azure DevOps Organization URL.
- Azure DevOps Organization new/existing Agent Pools.
- Azure DevOps Personal Access Token (PAT); you can see the documented [PAT](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#authenticate-with-a-personal-access-token-pat) & for now, keep the PAT at your device 1st)
- Azure Cloud Account

## Steps

### To Use
- Change the values of parameter in "terraform.tfvars.sample" file and rename to "terraform.tfvars"
- Upload the "devops_win.ps1" file to your Azure Storage Account, create the SAS Token for the file then update SASTOKEN in main.tf.
- Initial our Terraform script by execute command below:
`terraform init`
- Validate and check your terraform format:
`terraform validate && terraform fmt`
- Create a Terraform Plan
`terraform plan` OR `terraform plan -out=tfplan`
- After confirmed and validated your parameter, execute command below to create new Azure DevOps Agent.
`terraform apply -auto-approve -var-file=terraform.tfvars` OR `terraform apply tfplan -var-file=terraform.tfvar`

### To Test New Agent Pool
- Use 'pipeline.yaml' as our sample Build(CI) pipeline script

# Clean Up
- To clean up all the resources provisoned by Terraform , run command below:
`terraform destroy -auto-approve -var-file=terraform.tfvars` 