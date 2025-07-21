docker run --name pl01 -d -p9002:9002 plumber-test

## Test calls:
http://localhost:9002/echo?msg=test
http://127.0.0.1:9002/plot
