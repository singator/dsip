library(tidyverse)
library(readxl)

git_ignore_lines <- readLines("all_git_ignore_lines.txt") %>% 
  Filter(function(x) str_detect(x, "^#", negate = TRUE), .) %>% 
  Filter(function(x) x != "", .)

set.seed(3103)
s_info <- read_excel("../../batch_info/AY2223s1/dsa3101_roster_01-08-2022.xlsx") %>%  
  mutate(r_py = sample(c("r", "python"), size=NROW(s_info), replace=TRUE),
         gitignore = sample(git_ignore_lines, size=NROW(s_info), replace=FALSE))
         

py_tasks <- c("2. Use argparse to add a command line argument to choose the date-time string.",
              "2. Add a docstring to the script, explaining what it does.",
              "2. Use pandas to write the taxi coordinates to a csv file named coords.csv.\ncoords.csv should not be added to the repo.",
              "2. Write the number of taxis as a json string to a text file named taxi_count.json\n taxi_count.json should not be added to the repo.",
              "2. Add a try clause to catch any exceptions when making the http request.")

r_tasks <- c("2. Add a code chunk to create a bar chart of starting letter of male names.", 
             "2. Add a code chunk to create a bar chart of starting letter of female names.",
             "2. Add a code chunk to create a histogram of the number of characters in \nmale names.",
             "2. Add a code chunk to create a histogram of the number of characters in \nfemale names.",
             "2. Add a code chunk to print the number of names in both male and female lists.")
             
for(ii in 1:length(s_info$`Student SIS ID`)){
#for(ii in 1:5){
  uid <- s_info$`Student SIS ID`[ii]
  r_py <- s_info$r_py[ii]
  
  f_con <- file(file.path("all_files", paste0(uid, '_git_assignment.txt')), open='at')
  if(r_py == "r"){
     cat("1. Create a copy of male_female_plot.Rmd called", 
         paste0("male_female_plot_", str_sub(uid, start=2), ".Rmd"), 
         "\nin the same folder.\n",
         file = f_con, append = TRUE)
     cat(sample(r_tasks, size=1), "\n", file=f_con, append=TRUE)
     cat("3. Commit the Rmd file here, but commit the html output to the appropriate directory,\n",
         "on gh-pages branch.\n", file=f_con,  append = TRUE)
     cat("4. Make sure your page is visible at", 
     paste0("https://singator.github.io/dsa3101-2210/male_female_plot_", 
            str_sub(uid, start=2), ".html"), "\n", file=f_con, append=TRUE)
     cat("5. Add the following line to .gitignore on main branch:\n", 
         file=f_con, append=TRUE)
     cat(s_info$gitignore[ii], "\n", file=f_con, append=TRUE)
    
  } else {
     cat("1. Switch to branch pycode and create a copy of data_gov.py called",  
         paste0("data_gov_",str_sub(uid, start=2), ".py"), 
         "\nin the same folder.\n",
         file=f_con, append=TRUE)
     cat(sample(py_tasks, size=1), "\n", file=f_con, append=TRUE)
     cat("3. Commit your changes in this folder.\n", file=f_con, append = TRUE)
     cat("4. Add the following line to .gitignore on this branch:\n", 
         file=f_con, append=TRUE)
     cat(s_info$gitignore[ii], "\n", file=f_con, append=TRUE)
    
  }
   cat("\n------------\n", "Do not add unnecessary files to the repository!\n",
       "This is our chance to experiment and get better at git.", 
       file=f_con, append=TRUE)
   
  close(f_con)
  
}
