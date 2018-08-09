#!/usr/bin/awk -f
# input  : straw output of a chromosome
# output : DI value of each bin

function abs(v) {return v < 0 ? -v : v} #get absolute value

BEGIN{
  block_size = 40
  res = 50000
  max_bin = 0
}

$2/res + 1 > max_bin{
  max_bin = $2/res
}


$3 != "NaN" && ($2 - $1)/res <= block_size {
  for (i=$2/res; i <= $1/res + block_size; i++){
    A[i] += $3
  }
  
  for (i=$2/res - block_size; i <= $1; i++){
    if(i <= 0){continue}
    B[i] += $3
  }

}

END{
  for(i=1;i<=max_bin;i++){
    if(!(i in A)){a = 0}
    if(!(i in B)){b = 0}
    if(a == 0 && b== 0 || a == b){DI = 0} # avoid divide by 0 error
    else{
    e = (a+b)/2
    DI = ((b-a)/abs(b-a))*((a-e)^2/e + (b-e)^2/e)  # compute DI
    }
    print DI
  }
}
