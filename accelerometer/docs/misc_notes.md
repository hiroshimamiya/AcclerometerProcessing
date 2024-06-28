Original Walmsley paper: https://bjsm.bmj.com/content/56/18/1008#DC1
 
In their calculation:
2501 hours
how many 30 second data rows?
2501 * 60 * 2 = 300,120 ~ total data rows
- Q: Did they mention anything about dropping data rows from this set?
- Because in table-1, they have 150,086 total observations.
Clarification:
if you consider 24 hour data for 151 participants, it means: 24*151 = 3624
which means they did not use all the data.
 
In our confusion matrix:
We used 24 * 151 * 60 * 2 = 434,880 (total set)
we dropped 169,301 out of this (NA values, duplicates, time stamp mismatch) leaving us with = 265,579 usable data








We have x, y, z coordinates. They were combining x,y,z coordinates by taking the vector magnitude and then getting the median, min, max, 25thp, 75thp for those values.
What we added was, we took the median, min, max, 25thp, 75thp values for x,y,z directions separately. We added these extra 5 features per direction (~15 in total) to the existing feature set they had. We also kept existing percentiles as well for the combined vector.
 
        header += ",medianx,minx,maxx,25thpx,75thpx, iqrx";
        header += ",mediany,miny,maxy,25thpy,75thpy, iqry";
        header += ",medianz,minz,maxz,25thpz,75thpz, iqrz";               
        header += ",median,min,max,25thp,75thp";









