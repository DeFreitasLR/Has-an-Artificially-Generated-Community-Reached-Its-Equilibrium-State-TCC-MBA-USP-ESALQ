source(here::here("R","Simulations","TWoLife.R"))

indspec<-function(N, TNW , BIC , Method = 2 ){
  
  
  
  WIC<- TNW - BIC
  
  
  ind<- matrix(nrow = N, ncol = 2) 
  colnames(ind) <- c("genotype_Mean", "width_sd") 
  
  
  #Random
  
  if(Method ==  0 || Method == "random" || Method == "Random"){
    
    for (i in 1:N) {
      
      for (i in 1:N) {
        ind[i,1]<- runif(1,(1-(TNW-(WIC/2))),(1-(WIC/2)))
      }
    }
    
  }
  
  
  #Sistematical
  
  if(Method == 1 || Method =="sistematical"  || Method == "Sistematical"){
    
    ind[,1] <-seq(from = (1-(TNW-(WIC/2))), to= (1-(WIC/2)), length.out = N)
    
  }
  
  #Normal
  
  if(Method ==  2 || Method == "Normal" ||  Method == "Normal"){
    
    for (i in 1:N) {
      
      ind[i]<- rnorm(1,(1-(TNW/2)),BIC/2)
      while (ind[i,1]<(1-(TNW-(WIC/2))) || ind[i,1]>(1-(WIC/2))) {
        ind[i]<- rnorm(1,(1-(TNW/2)),BIC/2)
      }
    }
  }
  
  ind[,2]<-sqrt(WIC)
  
  return(ind)
}

library("rflsgen")

# inputs
setwd("C:/Users/Lucas Freitas/Desktop/The_Landscape_Ecology_of_Variable_Individuals/data/inputs")

LHS<-read.csv("Hipercubo.csv", row.names = 1)
lines<-nrow(LHS)

#Functions
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

# creates an object for storing the selection times

#Sets non-LHS  Parameters
Nind=1000
density.type=1
ini.config=1
i=1
rep=1
side=100

count=0
mbaresults<-matrix(ncol = 5,nrow= 1000)

for (rep in 1:10) { #Loops Independent Replicates
  
  for (i in 1:1) { #Loops Hipercube Lines
    
    #sets Hipercube line values
    raio<-LHS$R[i]
    passo<-LHS$S[i]
    taxa.basal<-LHS$BB[i]
    taxa.morte<-LHS$BD[i]
    taxa.move<-LHS$MR[i]
    incl.birth<-LHS$Binc[i]
    death.mat<- LHS$DM[i]
    G<-LHS$G[i]
    TNW<-LHS$TNW[i]
    BIC<-LHS$BIC[i]
    H<-0.5
    M<-TNW
    sd<-BIC
    
    #Sets Landscape and converts it into a perfect landscape for the individuals
    land<-Landscape()
    land$scape<-((range01(as.matrix(flsgen_terrain(side,side,H)))*M)+(1-M))
    
    #Sets maximum time to 1000 Generations
    max= 1000*G
    esp<- seq(from= G*1, to=(G*100),length.out = 100)
    
    q=1
    for (q in 1:length(esp)) { #Loops Time interval
      
      #creates a Folder For Storing the Outputs
      setwd("C:/Users/Lucas Freitas/Desktop/The_Landscape_Ecology_of_Variable_Individuals/data/output/SimulationResults/data-raw")
      name<-paste(i,q,rep)
      dir.create(name)
      name<-paste("C:/Users/Lucas Freitas/Desktop/The_Landscape_Ecology_of_Variable_Individuals/data/output/SimulationResults/data-raw/",name, sep ="")
      setwd(name)
      
      # Creates initial Individuals
      inds<-indspec(Nind,M,sd)
      x<- inds[,1]
      y<- inds[,2]
      
      # Runs First Simulation
      w<-TWoLife(landscape = land,
                 N = Nind,
                 raio=raio,
                 passo=passo,
                 taxa.move=taxa.move,
                 taxa.basal=taxa.basal,
                 taxa.morte=taxa.morte,
                 incl.birth=incl.birth,
                 death.mat=death.mat,
                 ini.config=ini.config,
                 density.type=density.type,
                 genotype_means= x,
                 width_sds= y,
                 out.code = 1,
                 points = rep(10,Nind),
                 tempo = esp[q]
      ) 
      
      #stores initial conditions
      write.csv(w,"initial")
      
      # Passes conditions to the replicates
      posx<- w[,1]
      posy<- w[,2]
      xt<- w[,3]
      yt = rep(y[1],length(xt))
      
      if(length(posx>1)){
        
        
        for (h in 2:2) { # Loops Dependent Replicates (The amount of independent continuations to a given initial condition)
          
          #runs Simulations
          w<-TWoLife(landscape = land,
                     N = length(posx),
                     raio=raio,
                     passo=passo,
                     taxa.move=taxa.move,
                     taxa.basal=taxa.basal,
                     taxa.morte=taxa.morte,
                     incl.birth=incl.birth,
                     death.mat=death.mat,
                     ini.config=3,
                     density.type=density.type,
                     genotype_means= xt,
                     width_sds= yt,
                     out.code = h,
                     initialPosX = posx,
                     initialPosY = posy,
                     points = rep(10,length(posx)),
                     tempo = (max-q)
          ) 
          
          
        } # Loops Replicates
      } # ends if
      
      
      tryCatch({
        
        #initial<-w
        #posx<-nrow(initial)
        
        
        w<-eventoswin("2",length(posx),G)
        
        resp=cbind(w$trait,w$offspring)
        colnames(resp)<-c("trait", "offspring")
        resp<-as.data.frame(resp)
        
        trait<-as.numeric(resp$trait)
        offspring<-as.numeric(resp$offspring)
        
        resp<-data.frame(trait,offspring)
        
        modelos1<-(glm(resp$offspring~as.factor(resp$trait), family="poisson"))
        
        modelos2<-(glm(resp$offspring~1, family="poisson"))
        
        modelos3<-(glm(resp$offspring~(resp$trait), family="poisson"))
        
        
        a<-AIC(modelos1,modelos2,modelos3)
        
        count=count+1
        mbaresults[count,1]<-rep
        mbaresults[count,2]<-q
        mbaresults[count,3]<-a$AIC[1]
        mbaresults[count,4]<-a$AIC[2]
        mbaresults[count,5]<-a$AIC[3]
        
        
        
        
        
      }, error=function(e){})
      
      
      
      
    } #Loops Time interval
    
  }#Loops Hipercube Lines
  
}

