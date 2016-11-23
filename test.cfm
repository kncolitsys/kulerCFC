
<cfset k = createObject("component", "kuler").init("YOUR KEY GOES HERE...")>

<cfdump var="#k.getRecent()#" label="Recent" top="3" expand="false">

<cfdump var="#k.getPopular()#" label="Popular" top="3" expand="false">

<cfdump var="#k.getHighestRated()#" label="Highest Rated" top="3" expand="false">

<cfdump var="#k.getRandom()#" label="Random" top="3" expand="false">

<cfdump var="#k.getHighestRated(timespan=2)#" label="Highest Rated, timeSpan of 2" top="3" expand="false">

<!--- thumb, url  test --->
<cfoutput>
<a href="#k.getThemeURL(11)#"><img src="#k.getThumbURL(11)#"></a>
</cfoutput>
<cfdump var="#k.search('ocean')#" label="Search for ocean" top="3">

<cfdump var="#k.search(title='Asian')#" label="Search for title=Asian" top="3">

<cfdump var="#k.getComments(hr.id[1])#">
