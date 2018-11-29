library(Rcpp)
Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
sourceCpp('/YOUR/PATH/TO/straw/R/straw-R.cpp')
library(Matrix)
library(wvtool)
library(magrittr)
library(methods) # avoid script error



get_mat_from_hic <- function(hic_file,norm='KR',chr,res,
                             output = 'matrix'){
  # get string
  straw_string <- paste(norm, hic_file, chr, chr, 'BP', format(res, scientific = FALSE), sep=' ')
  # get matrix
  #res_int <- as.numeric(res)
  mat <- straw_R(straw_string)
  mat$counts[is.na(mat$counts)] <- 0
  # avoid 0 matrix
  if(max(mat$counts) == 0){
    straw_string <- paste('VC', hic_file, chr, chr, 'BP', format(res, scientific = FALSE), sep=' ')
    print("use VC normalization instead !")
    mat <- straw_R(straw_string)
    mat$counts[is.na(mat$counts)] <- 0
  }

  if(output == 'matrix'){
    mat <- with(mat,sparseMatrix(i=x/res + 1, j=y/res + 1, x=counts, symmetric = TRUE))
  }else if(output == 'dataframe'){
    # mat <- as.data.frame(cbind(mat$x/res + 1, mat$y/res + 1, mat$counts))
    mat <- with(mat,data.frame(x=x/res + 1, y=y/res + 1, counts=counts))
  }else {
    stop("can't recongnize argument: output")
  }
}

filter_loops <- function(loop_file, hic_file, chrList){
  res <- 5000

  loops <- read.table(loop_file,header = TRUE)

  loops <- with(loops,data.frame(chr=chr1,x1=x1/res + 1,x2=x2/res + 1,y1=y1/res + 1,y2=y2/res + 1))

  get_num <- function(x1,x2,y1,y2,enlarge=5,mat=NULL){ # use triplet dataframe format
    x1 <- x1 - enlarge
    y1 <- y1 - enlarge
    x2 <- x2 + enlarge
    y2 <- y2 + enlarge

    mat_size <- max(mat[,2])
    x1 <- ifelse(x1 > 0, x1, 1)
    y1 <- ifelse(y1 > 0, y1, 1)
    x2 <- ifelse(x2 > mat_size, mat_size, x2)
    y2 <- ifelse(y2 > mat_size, mat_size, y2)

    sub_mat_size <- (x2 - x1 + 1) * (y2 - y1 + 1)
    entry_num <- nrow(subset(mat, x>=x1 & x <= x2 & y>=y1 & y<=y2)) # count entry number
    mean_entry_num <- entry_num/sub_mat_size
  }

  all_loop_entry <- data.frame()

  for(chrom in chrList){
    mat <- get_mat_from_hic(hic_file, norm = 'NONE', chr = chrom, res = 5000, output = "dataframe")
    sub_loops <- subset(loops, chr == chrom)
    entry_num_list <- apply(sub_loops, MARGIN = 1, function(x,mat){get_num(as.numeric(x[2]),as.numeric(x[3]),as.numeric(x[4]),as.numeric(x[5]),mat=mat)},
          mat = mat)
    sub_loops <- cbind(sub_loops,entry_num=entry_num_list)
    all_loop_entry <- rbind(all_loop_entry, sub_loops)
  }
  all_loop_entry <- with(all_loop_entry,data.frame(chr1=chr,x1=(x1-1)*res,x2=(x2-1)*res,chr2=chr,y1=(y1-1)*res,y2=(y2-1)*res),color='0,255,255')
}