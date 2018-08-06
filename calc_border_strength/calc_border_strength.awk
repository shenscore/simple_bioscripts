# input : straw output of a chromosome
# param : block_size

BEGIN{
  block_size = 8
  res = 5000
}

($2-$1)/res < block_size {
  $2/res + 1, $1/res + 8
  block_A
}

($2-$1)/res < block_size {
  $2/res - 8, $1/res - 1
  block_B
}

($2-$1)/res <= block_size {
  ($2+$1)/res/2 - ($2-$1)/res/2, ($2+$1)/res/2 + ($2-$1)/res/2
  block_C
}

($2-$1)/res <= 2*block_size && ($2-$1)/res > block_size{
  ($2+$1)/res/2 - (($2-$1)/res/2 - 4), ($2+$1)/res/2 + (($2-$1)/res/2 - 4)
}
