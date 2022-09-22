library(devtools)

x <- seq(-pi,pi,0.1)
#plot(x, sin(x),col="dodgerblue2",pch=20)
#points(x,cos(x),col="indianred",pch=20)

j = runif(100)
k = runif(100)
#plot(j,k,pch=20,col="mediumorchid2")

pdf("~/ccbb_projects/pretty_plot.pdf")
plot(x, sin(x),col="dodgerblue2",pch=20)
points(x,cos(x),col="indianred",pch=20)
plot(j,k,col="mediumorchid2",pch=20)
dev.off()
