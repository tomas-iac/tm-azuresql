# tm-azuresqk
Terraform module - Azure SQL

## Module testing

```bash
cd examples/local
terraform validate
terraform plan
terraform apply -auto-approve
```

## Tests
cd tests
go mod init azuresql
go get github.com/gruntwork-io/terratest/modules/terraform
go test -timeout 60m