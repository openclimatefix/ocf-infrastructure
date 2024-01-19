
# India Solar and Wind (Development)

This folder specifies all relevant components to run this project on AWS.
All resources are specified in Terraform. By using Terraform anybody can run this script themselves.

## Setup

Install the terraform cli: https://learn.hashicorp.com/tutorials/terraform/install-cli. 
Initialize terraform by running `terraform init` in this directory.

## Configuration

The configuration options are specified in `variables.tf`.

## System Diagram

```mermaid
graph TD;
      D1[ RUVNL Consumer] -->A;
      D2[ NWP Consumers] -->A2;
      D3[ Satellite Consumer] -->A2;
      subgraph Airflow
      D1
      D2
      D3
      F
      A2
      E
      end
      A --> F
      A2(S3 Bucket) --> F
      F[Forecasts] -->A ;
      A(RDS Database)-->D;
      D[API];
      D-->U[UI];
      D --> E[Email];
      E --> U2[User];
      U --> U2;
      D --> U2
```

## Infrastructure

### RUNVNL Consumer

This consumer pulls data from the Rajasthan Urja Vikas Nigam Limited (RUVNL) website.

### NWP Consumers

These consumers pull NWP data from various sources.

### Satellite Consumer

This consumer pulls satellite data from IOPS

### Forecasts

This runs the forecast service and saves the result to the database


### API

The API serves the generation and forecast values to the UI, the Email service and other users.

### UI

The UI is a simple web app that shows the generation and forecast values.

### Email

An Email service that sends out regular emails to users.