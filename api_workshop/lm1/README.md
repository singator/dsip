docker build -t lm1 .
#docker logs lm1-01
#docker stop lm1-01
#docker container rm lm1-01
docker run --name lm1-01 -p5000:5000 -d lm1
