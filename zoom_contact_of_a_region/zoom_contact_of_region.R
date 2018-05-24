library(Rcpp)
Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
sourceCpp('~/wshen/00.soft/straw/R/straw-R.cpp')
library(Matrix)
library(wvtool)
library(magrittr)



zoom_contact <- function(hic_file, region, res){
  chr <- region[1]
  reg_sta <- as.integer(as.integer(region[2])/res)
  reg_end <- as.integer(as.integer(region[3])/res)

  straw_string <- paste('KR', hic_file, chr, chr, 'BP', res,sep=' ')
  mat <- straw_R(straw_string)
  mat$counts[is.na(mat$counts)] <- 0

  mat$x <- mat$x/res + 1
  mat$y <- mat$y/res + 1

  sub_mat <- mat[mat$x > reg_sta & mat$x < reg_end & mat$y > reg_sta & mat$y < reg_end,]

  start_bin <- min(sub_mat$x,sub_mat$y)

  sub_mat$x <- sub_mat$x - start_bin + 1
  sub_mat$y <- sub_mat$y - start_bin + 1

  sub_mat <- with(sub_mat,sparseMatrix(i=x, j=y, x=counts, symmetric = TRUE))

  print(dim(sub_mat)[1])
  par(mar=rep(2,4))
  q95 <- quantile(as.vector(sub_mat),0.95)[[1]]
  max_value <- max(sub_mat)
  breaks <- c(seq(0,q95,length.out = 100),max_value)
  image_col <- colorRampPalette(c('white','red'))(100)
  #image
  image(rot90c(sub_mat),col = image_col, breaks = breaks, useRaster = TRUE, axes = FALSE, main=paste(region,collapse = '-'))
}
