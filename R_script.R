printer = function(i){
  output = paste0("This is loop #",i)
  print(output)
}
x=sapply(1:3,printer)
