#from Shuting - pull into new file

# ####next step is to add discrete data once they are in
# 
# #left_join will keep the rows of master file, and add new columns from joining data frame
# #nutrient for example
# merge<-read.csv("AE2213_nut.csv", header=T)
# #make sure you include ID for merging, and matching header name with master header
# colnames(merge)<-c("ID","NO3.NO2.umol.kg.","PO4.umol.kg.")
# #calculate NO3 from N+N and NO2 if it is BATS cruise, we don't measure NO2 for BIOSSCOPE cruise
# merge$NO3.umol.kg.<-ifelse(merge$NO3.NO2.umol.kg.!=-999 & new$NO2.umol.kg.!=-999, new$NO3.NO2.umol.kg.-new$NO2.umol.kg., -999)
# merge$NO3.umol.kg.<-ifelse(merge$NO3.umol.kg.<0 & merge$NO3.umol.kg.!=-999,0,merge$NO3.umol.kg.)
# 
# #make sure ID class are the same as master, if not, change to character
# class(new_master$ID)
# class(merge$ID)
# merge$ID<-as.character(merge$ID)
# 
# new_master_merge<-left_join(new_master,merge,by="ID") #left join keep same rows as new_master rows, if there are new rows, you may want to use full_join()
# #this will create two new columns with same header as .x and .y, new data in .y and old data in .x
# #merge these two
# new_master_merge[which(new_master_merge$ID %in% merge$ID),]$NO3.NO2.umol.kg..x<-new_master_merge[which(new_master_merge$ID %in% merge$ID),]$NO3.NO2.umol.kg..y
# new_master_merge[which(new_master_merge$ID %in% merge$ID),]$PO4.umol.kg..x<-new_master_merge[which(new_master_merge$ID %in% merge$ID),]$PO4.umol.kg..y
# new_master_merge<-new_master_merge[,-c(138:139)] #delete .y columns
# colnames(new_master_merge)[c(31,37)]<-c("NO3.NO2.umol.kg.","PO4.umol.kg.") #change back column name without x or y
# 
# 
# write.csv(new_master_merge,"new_master_merge.csv",row.names=F) #replace old with this new data sheet 
