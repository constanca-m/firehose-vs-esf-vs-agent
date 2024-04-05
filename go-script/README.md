**Warning**: Run the terraform files before running the go file in this directory.

Workflow of what happens when running `main.go`:

1. We will enter the directory defined in `terraformDir`:
   1. We will open all files `*.auto.tfvars`.
   2. We will read every variable inside these files and save them in a map, both the key and the value of the variable.
2. We will create a new AWS session. For this, make sure that the following variables were present in the `*.auto.tfvars` files:
   - `aws_region`
   - `aws_access_key`
   - `aws_secret_key`
   - `resource_name_prefix`
3. We will obtain the Cloudwatch Logs Group named `${resource_name_prefix}-cloudwatch-lg`.
4. We will create a new log stream inside this group.
5. We will send logs periodically to this log stream.