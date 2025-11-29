#!/bin/bash

################################################################################
# Amal - task2 - devops-internship
# Purpose: Build Spring PetClinic WAR file

################################################################################

# Exit on any error
set -e

# Step 1: Set Java path 
JAVA_HOME="/home/pet-clinic/java/jdk-17.0.9"

# Step 2: Set Maven path
MAVEN_HOME="/home/amal/devops/maven"

# Step 3: Set PetClinic path
PETCLINIC_HOME="/home/amal/devops/petclinic"

################################################################################
# BUILD PETCLINIC
################################################################################

echo "Step 1: Setting up environment..."
export JAVA_HOME
export PATH="${MAVEN_HOME}/bin:${PATH}"

echo "JAVA_HOME: $JAVA_HOME"
echo "MAVEN_HOME: $MAVEN_HOME"

echo ""
echo "Step 2: Checking Java version..."
java -version

echo ""
echo "Step 3: Checking Maven version..."
mvn -version

echo ""
echo "Step 4: Building PetClinic WAR file..."
cd "${PETCLINIC_HOME}"
mvn package -DskipTests -Denforcer.skip=true -Dspring-javaformat.skip=true

echo ""
echo "Step 5: Build complete!"
echo "WAR file created:"
ls -la target/*.war