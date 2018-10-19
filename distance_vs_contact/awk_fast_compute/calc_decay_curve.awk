$3 != "nan" {
  dist[$2-$1] += $3; sum += $3
}

END{
  chr_len=$2
  for(k=0;k<=chr_len;k+=res){
    if(k in dist){
      freq=dist[k]/sum/((chr_len - k)/res + 1)
      print k,freq
    }
    else{
      print k,0
    }
  }
}
