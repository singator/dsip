FROM rocker/tidyverse

RUN install2.r -s plumber

WORKDIR /app

COPY hdb/plumber.R .
COPY hdb/lm1.rds .
COPY hdb/hdb4.rds .
COPY plumber_script.R .

CMD ["R", "CMD", "BATCH", "plumber_script.R"]
