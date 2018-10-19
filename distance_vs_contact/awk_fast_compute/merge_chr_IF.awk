BEGIN{max_dis = 0}

{
  cont[$1] += $2; count[$1] ++
  
}
max_dis < $1 {max_dis = $1}

END{
  
  for(k=0;k<=max_dis;k+=res){
    if(cont[k] != 0){
      freq=cont[k]/count[k]
      print k,freq
    }
    else{
      print k,0
    }
  }
}
