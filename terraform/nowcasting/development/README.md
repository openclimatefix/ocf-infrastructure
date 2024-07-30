# Nowcasting (Development)

This folder specifies all relevant components to run this project on AWS.
All resources are specified in Terraform. By using Terraform anybody can run this script themselves.

## Setup

Install the terraform cli: https://learn.hashicorp.com/tutorials/terraform/install-cli. 
Initialize terraform by running `terraform init` in this directory.

## Configuration

The configuration options are specified in `variables.tf`.


## Infrastructure

There are several components to the system:

### ☁️ NWP Consumer (ECS Task):
Gets the latest NWP data from the UK Met Office and saves the data to S3. This is run on ECS and is triggered by airflow. This is currently part of the `nowcasting` project. There are currently two different orders. 
- The first gets data for the next 12 hours with the following variables: `dlwrf`, `dswrf`, `hcc`, `lcc`, `mcc`, `prate`, `r`, `sde`, `si10`, `t`, `vis` .
- The second gets data for the next 42 hours with the following variables:  `dswrf` `lcc` `sde` `t` `wdir10`

More details:
   - Code: [nwp-consumer](https://github.com/openclimatefix/nwp-consumer)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/nwp) 
and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/nwp-dag.py)
   - AWS logs: [aws/ecs/consumer/nwp](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fconsumer$252Fnwp$252F) 
and [aws/ecs/consumer/nwp-national](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fconsumer$252Fnwp-national$252F) 

### 🌍Satellite Consumer (ECS Task)
Gets the latest satellite data from the EUMETSAT and saves the data to S3. This is run on ECS and is triggered by airflow. This is currently part of the `nowcasting` project.
   - Code: [Satip](https://github.com/openclimatefix/Satip)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/sat) 
  and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/satellite-dag.py)
  - AWS logs: [aws/ecs/consumer/sat](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fconsumer$252Fsat$252F) 

### ☀️ PV Consumer (ECS Task):
Gets the latest PV data from the Sheffield Solar API and save to the database. This is run on ECS and is triggered by airflow. This is currently part of the `nowcasting` project. 
   - Code: [PVConsumer](https://github.com/openclimatefix/PVConsumer)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/pv)
and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/pv-dag.py)
   - AWS logs: [aws/ecs/consumer/pv](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fconsumer$252Fpv$252F) 

### ☀️ GSP Consumer (ECS Task):
Gets GSP solar generation data from PVlive from Sheffield Solar and save to the database. This is run on ECS and is triggered by airflow. This is currently part of the `nowcasting` project. 
   - Code: [GSPConsumer](https://github.com/openclimatefix/GSPConsumer)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/gsp)
and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/gsp-dag.py)
   - AWS logs: [aws/ecs/consumer/gsp](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fconsumer$252Fgsp$252F) 


### 📈 Site Forecast Prediction (ECS Task)
Loads NWP and PV data, and then runs the forecast model. The results are saved to the database. This is run on ECS and is triggered by airflow.
   - Code: [pv-site-production](https://github.com/openclimatefix/pv-site-production)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/forecast_generic) 
and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/forecast-site-dag.py)
   - AWS logs: [aws/ecs/pvsite_forecast/](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fpvsite_forecast$252F)

### 📈 GSP Forecast Prediction (PVnet 2) (ECS Task)
Pvnet 2 is currently our best forecast from 0 to 8 hours. It is a complex CNN model that used Satellite and NWP. First GSP forecasts are made, and then a model is used to forecast the national PV generation.
   - Code: [PVnet](https://github.com/openclimatefix/Pvnet), [PVnet national](https://github.com/openclimatefix/Pvnet-summation) and [PVnet App](https://github.com/openclimatefix/Pvnet_app)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/forecast_generic) 
and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/forecastg-gsp-dag.py)
   - AWS logs: [aws/ecs/forecast_pvnet/](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fforecast_pvnet$252F)

### 📈 DA GSP Forecast Prediction (PVnet Day Ahead) (ECS Task)
Pvnet Day Head is our PVnet model fro 0 to 36 hours. It is a complex CNN model that used Satellite and NWP. First GSP forecasts are made, and then added up for a national PV generation.
   - Code: [PVnet](https://github.com/openclimatefix/Pvnet), [PVnet App](https://github.com/openclimatefix/Pvnet_app)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/forecast_generic)
and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/forecastg-gsp-dag.py)
   - AWS logs: [aws/ecs/forecast_pvnet_day_ahead/](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fforecast_pvnet_day_ahead$252F)

### National Forecast Prediction (XGBoost) (ECS Task)
National xg makes forecast from 0 to 36 hours. It is a XGBoost model that used Satellite and NWP data. It prdocues a National forecast with probabilistic forecasts.

   - code: [uk-pv-national-xg](https://github.com/openclimatefix/uk-pv-national-xg)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/forecast_generic) 
and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/forecastg-national-dag.py)
   - AWS logs: [aws/ecs/forecast_national/](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fforecast_national$252F)

### Forecast Blend (ECS Task)
The Forecast blend service reads all of the above forecasts and blends them together apprioately.

   - Code: [uk-pv-forecast-blend](https://github.com/openclimatefix/uk-pv-forecast-blend)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/forecast_blend) 
and [Airflow Dag (GSP)](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/forecastg-gsp-dag.py) and [Airflow Dag (National)](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/forecastg-national-dag.py)
   - AWS logs: [aws/ecs/forecast_blend/](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Fecs$252Fforecast_blend$252F)

### 🚀 UK API (Elastic Beanstalk App)
The API loads forecasts and true values from the database and present the data in an easy to read way. This is run on Elastic Beantstalk. We use Auth0 to authenticate this API.
   - Code: [uk-pv-national-gsp-api](https://github.com/openclimatefix/uk-pv-national-gsp-api)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/api) 
   - [AWS logs on development](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Felasticbeanstalk$252Fnowcasting-api-development$252Fvar$252Flog$252Feb-docker$252Fcontainers$252Feb-current-app$252Fstdouterr.log)
 and [AWS logs on production](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Felasticbeanstalk$252Fnowcasting-api-production$252Fvar$252Flog$252Feb-docker$252Fcontainers$252Feb-current-app$252Fstdouterr.log)

### 🚀 Site API (Elastic Beanstalk App)
The API loads forecasts and true values from the database and present the data in an easy to read way. This is run on Elastic Beantstalk. We use Auth0 to authenticate this API.
   - Code: [pv-site-api](https://github.com/openclimatefix/pv-site-api)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/api_site) 
   - [AWS logs](https://eu-west-1.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/$252Faws$252Felasticbeanstalk$252Fpvsite-production-api-sites$252Fvar$252Flog$252Feb-docker$252Fcontainers$252Feb-current-app$252Fstdouterr.log)

### Other components:
- Databases: We have a few postgres database that store the PV and forecast data. These is run on RDS.
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/storage/postgres) 
- Site databases clean up: Once a day we run a service to remove any data that is more than ~3 days old. 
   - [Python Code](https://github.com/openclimatefix/pv-site-production/tree/main/database-cleanup)
   - [Terraform](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/modules/services/database_clean_up) 
 and [Airflow Dag](https://github.com/openclimatefix/ocf-infrastructure/blob/main/terraform/modules/services/airflow/dags/uk/forecast-site-dag.py#L49)
- Airflow is used to trigger the ECS tasks. They use the latest ECS Task definition. This is part of the [ocf airflow project](https://github.com/openclimatefix/ocf-infrastructure/tree/main/terraform/airflow). 
- OCF Dashboard: This is use for internally looking at the forecasts. Also for managing `sites` and `users`. 


The forecast is trained offline and the model weights are saved to s3. [Python Code](https://github.com/openclimatefix/pv-site-prediction)
