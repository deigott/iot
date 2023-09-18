#!/bin/bash

# Set your GitLab username and project name
USERNAME="root"
PROJECT_NAME="iotapplication"
ACCESS_TOKEN="glpat-5zQRE2qdJhjyosZsnRbT"
GITLAB_API="https://gitlab.mashad.ma/api/v4"

# Create a new GitLab project
echo "Creating a new GitLab project..."
curl --request POST --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "$GITLAB_API/projects?name=$PROJECT_NAME"

# Clone the newly created project
echo "Cloning the GitLab project..."
git clone "https://gitlab.mashad.ma/$USERNAME/$PROJECT_NAME.git"
cd "$PROJECT_NAME"

# Add your code files to the repository
echo "Adding your code files to the repository..."
cp /home/dipsy/projects/iot/bonus/iot/bonus/arogapp/* .

# Stage and commit your changes
echo "Staging and committing your changes..."
git add .
git commit -m "Initial commit"

# Push your code to GitLab
echo "Pushing your code to GitLab..."
git push origin master

# Verify the repository on GitLab
echo "Verification: Visit your GitLab project in your web browser to verify the code."

echo "
