export TF_VAR_gcp_project=$(gcloud config get project)
export GCS_BUCKET="qadevoprac3-capstone-bucket-$RANDOM-$RANDOM"
printf "Creating Bucket\n\n"
gcloud storage buckets create gs://$GCS_BUCKET --location=europe-west1
printf "\n\nCreated Bucket: %s\n" $GCS_BUCKET
wget https://raw.githubusercontent.com/qa-tech-training/qadevoprac3-capstone-lab-starter/refs/heads/main/jenkins.tf
terraform init > terraform.log 2>&1
terraform apply -auto-approve >> terraform.log 2>&1
terraform output
