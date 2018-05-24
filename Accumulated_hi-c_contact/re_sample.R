#for resample hic simplify.txt file

resample_by_size <- function(sample_size, circle = 100){

  uniq_series <- sapply(1:circle, resample_once, sample_size = sample_size)
  return(mean(uniq_series))

}

resample_once <- function(no_use, sample_size){
  return(length(unique(sample(input, sample_size))))
}

args = commandArgs(trailingOnly = TRUE)

data <- read.table(args[1])
input <<- rep(data[,2],data[,1])
remove(data)

sample_reads <- seq(3e6,3e8,length.out = 100)

uniq_reads <- sapply(sample_reads, resample_by_size)

to_save <- cbind(sample_reads, uniq_reads)
write.table(to_save, file = 'resample.result', sep = ' ', quote = FALSE, row.names = FALSE)

plot(sample_reads, uniq_reads, type = 'l')
