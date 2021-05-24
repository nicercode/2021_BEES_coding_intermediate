#!/usr/bin/env Rscript

# This file creates a folder for public release with
# - a subset of files
# - solutions removed
#
# To reduce duplication, we only need write a single Rmd file and then use this to auto-generate a file for exercises by stripping out some of the answers. 

# To achieve this, put solutions within in a chunk using the following format

# ```{r, drop}
# your code here
# ```

library(purrr)

release <- "public3/2021_bees_data_inter"

# delete any previous content
unlink(release, recursive = TRUE)

# create cirectory
dir.create(release, FALSE, TRUE)

# Copy top level md files
files <- list.files(pattern = ".md")
file.copy(files, file.path(release, files), overwrite = TRUE)

# copy directories
for( f in c("lessons", "slides", "cheatsheets") ) {
  if(file.exists(f))
    R.utils::copyDirectory(f, file.path(release, f))
}

# Remove files that don't want in public release
files <- 
  list.files(release, full.names = TRUE, recursive = TRUE, all.files = TRUE)

unwanted <- c("TODO", "DS_", "Rproj.user", "output", ".key")

for(f in unwanted)
  subset(files, grepl(f, files, fixed = TRUE)) %>% 
  unlink(recursive = TRUE)

# Remove solutions from Rmd files
# This function removes any content in Rmd files with the 
# following format
# ```{r, drop}
# your code here
# ```
remove_solutions <- function(file) {
  readLines(file) %>% 
  # Using `NNNN` for new line when collapsing because this doesn't interfere with string replacement whereas `\n` does
	stringr::str_c(collapse = "NNN") %>% 
  # the regular expression searches for everything between  `r, drop}` and three backticks and replaces this with two blank lines
	stringr::str_replace_all("r, drop.+?(?=\`\`\`)", "r}\n\n") %>%
	stringr::str_replace_all("NNN", "\n") %>%  
	writeLines(file)
}

list.files(release, full.names = TRUE, recursive = TRUE, all.files = TRUE, pattern = "\\.Rmd$") %>% 
  walk(remove_solutions)

