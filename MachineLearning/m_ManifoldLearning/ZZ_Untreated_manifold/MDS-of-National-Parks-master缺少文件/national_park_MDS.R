setwd('C:/Users/luxur/Desktop/Daehyun/UW/Math 381')
data <- read.table("dist_mat2.dat")
names <- read.csv("Names.csv", header = TRUE)
distances = data
ll <- cmdscale(distances, k=2)
library(wordcloud)
plot(ll)
textplot(ll[,1],ll[,2],names[,2],xlim=c(-0.5,0.5),cex=0.6)
cmdscale(distances,k=2,eig=TRUE)$GOF
cmdscale(dist(replicate(56,runif(20))),k=2,eig=TRUE)$GOF
plot(distances,dist(ll))
