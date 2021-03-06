#!/usr/bin/awk -f
# input : straw output of a chromosome
# param : block_size

BEGIN{
  #block_size = 8
  #res = 5000
  max_bin = 0
}


$2/res +1 > max_bin{
  max_bin = $2/res + 1
}

($2-$1)/res < block_size && $3!="NaN" {

  for(i=$2/res + 1; i<= $1/res + 8; i++){
    block_A[i] += $3
  }
  
  for(i=$2/res - 8; i<= $1/res - 1; i++){
    if(i <= 0){continue}
    block_B[i] += $3
  }
  
}



($2-$1)/res <= block_size  && $3!="NaN" {
  for(i=($2+$1)/res/2 - ($2-$1)/res/2; i <= ($2+$1)/res/2 + ($2-$1)/res/2; i++){
    if(i <= 0){continue}
    block_C[i] += $3
  }
}

#TODO : when block_size is not even

($2-$1)/res <= 2*block_size && ($2-$1)/res > block_size  && $3!="NaN" {
  for (i=($2+$1)/res/2 - (block_size - ($2-$1)/res/2); i<= ($2+$1)/res/2 + (block_size - ($2-$1)/res/2); i++){
    if(i <= 0){continue}
    block_C[i] += $3
  }
}


END{
  for(i=1;i<=max_bin;i++){
    if(i <= block_size || i > NR - block_size){print 0}
    else{
      if (i in block_A) {a=block_A[i]}
      else{a=0}
      
      if (i in block_B) {b=block_B[i]}
      else{b=0}
      
      if (i in block_C) {c=block_C[i]+1}
      else{c=1}
      
      
      border_strength = (a+b)/c
      print border_strength
    }
  }
}
