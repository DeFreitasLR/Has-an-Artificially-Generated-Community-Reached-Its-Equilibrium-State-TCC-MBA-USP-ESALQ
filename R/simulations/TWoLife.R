setwd(here::here("TWoLife"))

# Função "wrapper" para a chamada em C:
#
# Os passos abaixo foram adaptados de http://users.stat.umn.edu/~geyer/rc/

Sys.setenv("PKG_CPPFLAGS" = "-fopenmp -DPARALLEL") # liga biblioteca de paralelismo
system("rm TWoLife.so") #limpa sources velhos
system("rm TWoLife.o") #limpa sources velhos
system("rm TWoLife.dll") #limpa sources velhos
system ("R CMD SHLIB TWoLife.cpp") ## compila no R
dyn.load("TWoLife.dll") ## carrega os source resultantes como biblioteca dinamica no R

# Generates the landscape with specified conditions. 
# numb.cells represents both the lenght AND width of the landscape, so numb.cells=100 creates a 100x100 landscape
# Land.shape can be 0 = XXX or 1 = XXX.
# Bound.condition can be 0 = XXX or 1 = XXX. 

indspec<-function(N, Mean, sd ){
  
  
  ind<- matrix(nrow = N, ncol = 2) 
  colnames(ind) <- c("genotype_Mean", "width_sd") 
  
  
  #Sistematical
  
  ind[,1] <-seq(from = (1-(Mean)), to= (1), length.out = N)
  
  
  ind[,2]<-(sd)
  
  return(ind)
}

Landscape <- function (numb.cells = 100, cell.size = 1, land.shape = 1, type=c("random","blob"), bound.condition=0, cover=1) {
  type=match.arg(type)
  if(cover < 0 || cover > 1) {
    stop("Error creating landscape. Cover must be between 0 and 1")
  }
  # scape represents the actual landscape
  scape <- rep(1, numb.cells*numb.cells)
  if(cover < 1) {
    NtoRemove=round((1-cover)*numb.cells*numb.cells);
    if(type=="random") {
      while(NtoRemove>0)
      {
        i=round(runif(1,0,numb.cells-1));
        j=round(runif(1,0,numb.cells-1));
        # tests to see if this point has already been removed
        if(scape[1+numb.cells*j+i] == 1) {
          NtoRemove = NtoRemove - 1
          scape[1+numb.cells*j+i] = 0
        }
      }
    }
    if(type=="blob") {
      i=round(runif(1,0,numb.cells-1));
      j=round(runif(1,0,numb.cells-1));
      while(NtoRemove>0)
      {
        # tests to see if this point has already been removed
        if(scape[1+numb.cells*j+i] == 1) {
          NtoRemove = NtoRemove - 1
          scape[1+numb.cells*j+i] = 0
        }
        # Draft a new point to be removed (random walk!)
        if(sample(1:2,1) == 1) {
          i = i + (-1)**sample(1:2,1)
        } else {
          j = j + (-1)**sample(1:2,1)
        }
        if(i == -1) { i=numb.cells-1}
        if(i == numb.cells) { i=1}
        if(j == -1) { j=numb.cells-1}
        if(j == numb.cells) { j=1}
      }
    }
  }
  land <- list(numb.cells = numb.cells, cell.size=cell.size, land.shape=land.shape, type=type, bound.condition=bound.condition, cover=cover, scape=scape)
  class(land) <- "landscape"
  return(land)
}
eventoswin<-function(arquivo, npop, G){
  nlines <- as.integer(unlist(strsplit(system(paste('find /c /v ""', arquivo), intern=TRUE), split=" "))[3])
  dados = file(arquivo, "r")
  dpaisagem = readLines(dados, n=9)
  
  
  IDmax <- 0
  indID <- as.integer(rep(0, nlines))
  indM <- as.double(rep(-1, nlines))
  indT <- as.double(rep(NA, nlines))
  indB <- as.double(rep(NA, nlines))
  
  for(i in 1:npop)
  {
    lin = readLines(dados, n=1)
    lin<-strsplit(lin, " ")
    line <- unlist(lin)
    
    IDmax <- IDmax + 1
    indM[IDmax]<- line[6]
    indB[IDmax]<- line[1]
    
    
  }
  
  
  lin = readLines(dados, n=1)
  
  while(lin != "EOF")
  {
    lin<-strsplit(lin, " ")
    line <- unlist(lin)
    acao <-strtoi(line[2])
    ID<-strtoi(line[3])
    
    if(acao == 1)
    {
      
      indID[ID] <- indID[ID]+1
      
      IDmax <- IDmax + 1
      indM[IDmax]<- line[7]
      indB[IDmax]<- line[1]
      
    }
    if(acao == 0)
    {
      
      indT[ID]<- line[1]
      
    }
    last<-line[1]
    
    lin = readLines(dados, n=1)
  }
  
  close(dados)
  
  if(last<(1000*G)){
    laststat<- 1
  }
  else{
    laststat<- 0
  }
  
  
  return(resp<-list( trait=indM[1:IDmax],offspring=indID[1:IDmax],birth=indB[1:IDmax], death=indT[1:IDmax], last=c(last,laststat)))
  
}

TWoLife <- function (
    raio=0.1,
    N=80,
    AngVis=360,
    passo=5,
    taxa.move=0.5,
    taxa.basal=0.6,
    taxa.morte=0.1,
    incl.birth=0.5/0.01,
    incl.death=0,
    density.type=0,
    death.mat=7,
    move.mat=7,
    landscape,
    tempo=20,
    ini.config=0,
    out.code="1",
    genotype_means=(rep(1, N)),
    width_sds=(rep(0, N)), 
    points=(rep(0, N)),
    Null= FALSE,
    initialPosX= NULL,
    initialPosY= NULL
) 
{
  if(class(landscape) != "landscape") {
    stop("Error in function TWoLife: you must provide a valid landscape. See ?Landscape")
  }
  #if(raio>landscape$numb.cells*landscape$cell.size/2)
  #{stop("Error in function TWoLife: the radius must be lower than or equal to the half of landscape side (radius <= numb.cells*cell.size/2)")}
  
  saida.C <- .C("TWoLife",
                as.double(raio),# 1
                as.integer(N),# 2
                as.double(AngVis),# 3
                as.double(passo),# 4
                as.double(taxa.move),# 5
                as.double(taxa.basal),# 6
                as.double(taxa.morte),# 7
                as.double(incl.birth),# 8
                as.double(incl.death),# 9
                as.integer(landscape$numb.cells),# 10
                as.double(landscape$cell.size),# 11
                as.integer(landscape$land.shape),# 12
                as.integer(density.type),# 13
                as.double(death.mat), # 14
                as.double(move.mat), # 15
                as.integer(ini.config), #16
                as.integer(landscape$bound.condition), #17
                as.double(landscape$scape), #18
                as.double(tempo), #19
                as.double(initialPosX), #20
                as.double(initialPosY), # 21
                as.double(genotype_means), # 22
                as.double(width_sds), # 23
                as.integer(points), # 24
                as.logical (Null), # 25
                as.integer(0), #26
                as.double(rep(0, 500000)), # 27
                as.double(rep(0,500000)), # 28
                as.double(rep(0, 500000)), # 29
                as.character(out.code)# 30
                ## verificar se precisa definir o tamanho e se isto nao dará problemas (dois ultimos argumentos)
  )
  n <- saida.C[[26]]
  x <- saida.C[[27]]
  y <- saida.C[[28]]
  m <- saida.C[[29]]
  x <- x[1:n]; y <- y[1:n] ; m <- m[1:n];
  return(data.frame(x=x,y=y, m=m))
}

