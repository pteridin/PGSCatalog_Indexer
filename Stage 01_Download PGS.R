library(tidyverse)
library(glue)

getPGS <- function(x) {
  Sys.sleep(1)
  Filename <- glue("Scores/{x$polygenic_score_pgs_id}.gz")
  
  if(!file.exists(Filename))
    download.file(x$ftp_link,
                  Filename)
  
  read.table(gzfile(glue("Scores/{x$polygenic_score_pgs_id}.gz")),
             comment.char = "#",
             sep = "\t",
             header = T) -> df
  
  df$polygenic_score_pgs_id <- x$polygenic_score_pgs_id
  df
}

if(!dir.exists("Scores"))
  dir.create("Scores")

# Download Metadata -------------------------
download.file("http://ftp.ebi.ac.uk/pub/databases/spot/pgs/metadata/pgs_all_metadata.tar.gz",
              glue("Scores/pgs_all_metadata.tar.gz"))

untar("Scores/Recent_Metadata.tar.gz", 
      exdir="Scores")

Metadata_Scores <- read.csv("Scores/pgs_all_metadata_scores.csv", stringsAsFactors = F) %>% 
                    janitor::clean_names() 

# Get Genomic data ---------------------
Genome_Data <- Metadata_Scores %>% 
                rowwise() %>% 
                do(getPGS(.))

write.csv(Metadata_Scores, glue("Scores/Recent_Metadata_Scores.csv"))
write.csv(Genome_Data, glue("Scores/Recent_Genome_Data.csv"))