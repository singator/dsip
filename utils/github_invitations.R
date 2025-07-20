library(tidyverse)
library(httr)
library(readxl)
# Most of the endpoints can be obtained from here:
# https://docs.github.com/en/rest
# This is the endpoint for adding collaborators:
# https://docs.github.com/en/rest/collaborators/collaborators#add-a-repository-collaborator

# save your token in a file named "gh_token.txt"
base_url <- "https://api.github.com"
my_token = scan("gh_token.txt", what=character())

set_config(add_headers(Authorization = paste("token", my_token),
                       Accept = "application/vnd.github.v3+json",
                       `Content-Length` = 0))

# Read IDS
github_ids <- read_excel("../batch_info/AY2223s2/Submit github username(1-84).xlsx") %>% 
  pull(7)
id <- github_ids[1]

# Example calls to add collaborators to a repository.
for(id in github_ids) {
  cat(id, ":\n")
  commits_path <- paste0("/repos/singator/dsa3101-2220/collaborators/", id)
  ret_obj <- PUT(base_url, path=commits_path)
  message(http_status(ret_obj)$message)
}
