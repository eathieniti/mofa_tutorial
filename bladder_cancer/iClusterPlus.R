#install.packages('iCluster')
library("iCluster")

library(iClusterPlus)

library(GenomicRanges)
library(gplots)
library(lattice)


##NOTE ON pre processing: LOG first then standardize!!                                                  
highly_variable_genes_voom = read.csv('bladder_cancer/highly_variable_genes_normalized.csv', row.names = 1)
highly_variable_proteins_voom = read.csv('bladder_cancer/highly_variable_proteins_normalized.csv', row.names = 1)
highly_variable_genes_voom = read.csv('highly_variable_genes_mofa.csv', row.names = 1)
highly_variable_proteins_voom = read.csv('highly_variable_proteins_mofa.csv', row.names = 1)

data = list(mRNA = t(highly_variable_genes_voom), 
            proteomics = t(highly_variable_proteins_voom) )


param_str_icl<-paste0( 'DE_data','_', most_var, '_ng_g_', round(1/ng_g,2),'_ncomp_g_','_ng_p_', round(1/ng_p,2)  )



# Separate analysis
#K_genes=2
#fit.single_genes=iClusterPlus(dt1=as.matrix(data$mRNA),
#                              type=c( "gaussian"),
#                              lambda=c(0.04,0.61,0.90),K=K_genes,maxiter=20)

#fit.single_genes$clusters


#K_proteomics=2
#fit.single_proteomics=iClusterPlus(dt1=as.matrix(data$proteomics),
#                                   type=c( "gaussian"),
#                                   lambda=c(0.04,0.61,0.90),K=K_proteomics,maxiter=20)

#fit.single_proteomics$clusters



#fit.single=iClusterPlus(dt1=as.matrix(data$mRNA),dt2=as.matrix(data$proteomics),
#                          type=c("gaussian","gaussian"),
 #                         lambda=c(0.04,0.61,0.90),K=2,maxiter=10)




settings<-'bladder_cancer/settings/'
#### MODEL TUNING - k - number of clusters
## And save these data

# RUN THIS ON THE CLUSTER 
n.lambda<-233
for(k in 1:3){
  cv.fit = tune.iClusterPlus(cpus=4,dt1=as.matrix(data$mRNA),dt2=as.matrix(data$proteomics), 
                            type=c("gaussian","gaussian"),K=k, n.lambda=n.lambda,
                            scale.lambda=c(1,1,1),maxiter=20)
 save(cv.fit, file=paste(settings,"cv.fit.multi",n.lambda,"ng_", ng_g, "_", ng_p, k, ".Rdata",sep=""))
}





n.lambda<-13
for(k in 1:4){
  cv.fit = tune.iClusterPlus(cpus=1,dt1=as.matrix(data$proteomics), 
                             type=c("gaussian"),K=k, n.lambda=n.lambda,
                             scale.lambda=c(1,1,1),maxiter=20)
  save(cv.fit, file=paste(settings,"cv.fit.prot",n.lambda,k, "ng_", ng_p,  ".Rdata",sep=""))
}



for(k in 1:3){
	  cv.fit = tune.iClusterPlus(cpus=1,dt1=as.matrix(data$mRNA),
				                                  type=c("gaussian"),K=k, n.lambda=n.lambda,
								                               scale.lambda=c(1,1,1),maxiter=20)
 save(cv.fit, file=paste(settings,"cv.fit.gene",n.lambda, "ng_", ng_p,k,".Rdata",sep=""))
}



