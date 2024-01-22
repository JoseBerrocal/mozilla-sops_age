# Use an official Python runtime as a parent image
FROM mozilla/sops:latest

# Install any needed packages specified in requirements.txt
RUN apt-get update && apt-get -y install age
