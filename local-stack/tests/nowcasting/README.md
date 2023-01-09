# Local Stack

Within this folder are the files to be able to run the stack locally on your laptop

You'll need to add the following environmental variables
- NWP_API_KEY for Metoffice API
- NWP_API_SECRET for Metoffice API
- AWS_ACCESS_KEY_ID for AWS
- AWS_SECRET_ACCESS_KEY for AWS
- PVOUTPUT_API_KEY for PV api key
- PVOUTPUT_SYSTEM_ID for pv system id
- SAT_API_KEY for satellite consumer api key
- SAT_API_SECRET for satellite consumer api secret

If you make a `.env` and put these variables in there, they will then be used

Idea:
- Can run stack locally is useful for development
- Could be automated tests to check entire stack is working

Useful commands
 - `docker-compose up`: run the stack but detach from the terminal
 - `docker kill $(docker ps -q)`: kill all contains
 - `docker system prune`: get rid of docker files not needed
