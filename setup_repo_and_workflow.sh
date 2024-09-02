#!/bin/bash

# Variables
REPO_URL="https://github.com/HamzaYaqoob1025/TITALS12.git"
BRANCH_NAME="master"

# Step 1: Initialize Git and Add Files
echo "Initializing Git repository..."
git init

echo "Adding all extracted files to the repository..."
git add .
git commit -m "Initial commit: Add scripts and data"

# Step 2: Set Remote Repository
echo "Setting remote GitHub repository..."
git remote remove origin 2>/dev/null  # Remove existing remote if it exists
git remote add origin $REPO_URL

# Step 3: Push Initial Commit to GitHub
echo "Pushing initial commit to GitHub..."
git push -u origin $BRANCH_NAME

# Step 4: Create GitHub Actions Workflow
echo "Creating GitHub Actions workflow..."
mkdir -p .github/workflows
cat <<EOL > .github/workflows/run-scripts.yml
name: Run Scripts

on:
  push:
    branches:
      - $BRANCH_NAME

jobs:
  run-scripts:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '14'
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.8'
    
    - name: Install Node.js dependencies
      run: npm install

    - name: Install AWS CLI
      run: sudo apt-get install awscli -y

    - name: Configure AWS CLI
      run: aws configure set aws_access_key_id \${{ secrets.AWS_ACCESS_KEY_ID }} && \\
           aws configure set aws_secret_access_key \${{ secrets.AWS_SECRET_ACCESS_KEY }} && \\
           aws configure set region us-east-1

    - name: Run calc_position.js
      run: node calc_position.js Tile-54-26-1-1.zip

    - name: Run tiles.sh
      run: bash tiles.sh

    - name: Run blender_script.py
      run: python3 blender_script.py

    - name: Run test.sh
      run: bash test.sh
EOL

# Step 5: Push Workflow to GitHub
echo "Pushing GitHub Actions workflow to GitHub..."
git add .github/workflows/run-scripts.yml
git commit -m "Add GitHub Actions workflow"
git push origin $BRANCH_NAME

echo "Setup complete! Your GitHub repository and Actions workflow are ready."
