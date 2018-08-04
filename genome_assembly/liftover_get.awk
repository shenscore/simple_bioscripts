#!/usr/bin/awk -f
# input  : final.asm final.cprops 
# output : liftover chain file

BEGIN{
  gap = 500
  ref_start = 1
  #need chr defined
}


# asm file; only count first line
FILENAME == ARGV[1] && FNR == 1{
  asm_len = split($0,asm," ")
}

# cprops file
FILENAME == ARGV[2]{
  contig_len[$2]   = $3
  contig_start[$2] = $ref_start
  contig_end[$2]   = $ref_start + $3 - 1
  $ref_start       = $ref_start + $3
}
END{
  qStart = 1
  tName = chr
  qName = chr
  id = 1
  tStrand = "+"
  
  for(k=1;k<=asm_len;k++){
    if(asm[k] < 0){
      qStrand = "-"
      tSize   = contig_len[-asm[k]]
      qSize   = tSize
      qEnd    = qStart + contig_len[-asm[k]] - 1
      score   = tSize * 80
      print "chain", score, tName, tSize, tStrand, contig_start[-asm[k]], contig_end[-asm[k]], qName, qSize, qStrand, qStart, qEnd, id
      print  tSize
      qStart  = qEnd + 1
    }
    else{
      qStrand = "+"
      tSize   = contig_len[asm[k]]
      qSize   = tSize
      qEnd    = qStart + contig_len[asm[k]] - 1
      score   = tSize * 80
      print "chain", score, tName, tSize, tStrand, contig_start[asm[k]], contig_end[asm[k]], qName, qSize, qStrand, qStart, qEnd, id
      print  tSize
      qStart  = qEnd + 1
    }
    
    # add gap
    qStart = qStart + gap
    
  }
}
