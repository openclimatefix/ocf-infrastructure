# Local Stack

Within this folder are the files to be able to run the stack locally on your laptop

You'll need to add the following environmental variables
- API_KEY for Metoffice API
- API_SECRET for Metoffice API

If you make a `.env` and put these variables in there, they will then be used

Idea:
- Can run stack locally is useful for development
- Could be automated tests to check entire stack is working

Useful commands
 - `docker-compose up`: run the stack but detach from the terminal
 - `docker kill $(docker ps -q)`: kill all contains
 - `docker system prune`: get rid of docker files not needed
