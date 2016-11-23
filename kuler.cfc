<cfcomponent output="false" displayName="kuler API Component">

<cfset variables.apikey = "">
<cfset variables.baseurl = "http://kuler.adobe.com/kuler/API/">

<cffunction name="init" access="public" returnType="kuler" output="false">
	<cfargument name="apikey" type="string" required="true">
	<cfset variables.apikey = arguments.apikey>
	<cfreturn this>
</cffunction>

<cffunction name="get" access="private" returnType="query" output="false" hint="Utility function for get operations.">
	<cfargument name="listtype" type="string" required="true">
	<cfargument name="start" type="numeric" required="true">
	<cfargument name="max" type="numeric" required="true">
	<cfargument name="timeSpan" type="numeric" required="false" default="0">
	<cfset var myrul = "">
	
	<!--- kuler is 0 based for start --->
	<cfif arguments.start lt 0>
		<cfset arguments.start = 0>
	<cfelse>
		<cfset arguments.start = arguments.start - 1>
	</cfif>
	
	<!--- max can't be more than 100 --->
	<cfif arguments.max gt 100>
		<cfset arguments.start = 100>
	</cfif>
	
	<cfset myurl = variables.baseurl & "rss/get.cfm?listtype=#arguments.listtype#&startIndex=#arguments.start#&itemsPerPage=#arguments.max#&timespan=#arguments.timeSpan#&key=#urlEncodedFormat(variables.apikey)#">
	
	<cfreturn load(myurl)>
</cffunction>

<cffunction name="getComments" access="public" returnType="query" output="false" hint="Gets comments for a theme, or for all themes for a user.">
	<cfargument name="themeid" type="string" required="false">
	<cfargument name="email" type="string" required="false">
	
	<cfargument name="start" type="numeric" required="false" default="1">
	<cfargument name="max" type="numeric" required="false" default="20">
	
	<cfset var myurl = "">
	<cfset var result = "">
	<cfset var xmlresult = "">
	<cfset var totalcomments = "">
	<cfset var x = "">
	<cfset var item = "">
	
	<cfset var q = queryNew("themeid,comment,author,postedat,totalcomments")>
		
	<!--- kuler is 0 based for start --->
	<cfif arguments.start lt 0>
		<cfset arguments.start = 0>
	<cfelse>
		<cfset arguments.start = arguments.start - 1>
	</cfif>
	
	<!--- max can't be more than 100 --->
	<cfif arguments.max gt 100>
		<cfset arguments.start = 100>
	</cfif>

	<cfset myurl = variables.baseurl & "rss/comments.cfm?startIndex=#arguments.start#&itemsPerPage=#arguments.max#&key=#urlEncodedFormat(variables.apikey)#">
	
	<cfif structKeyExists(arguments,"themeid")>
		<cfset myurl = myurl & "&themeID=" & urlEncodedFormat(arguments.themeid)>
	<cfelseif structKeyExists(arguments,"email")>
		<cfset myurl = myurl & "&email=" & urlEncodedFormat(arguments.email)>
	<cfelse>
		<cfthrow message="getComments: Must provide either themeid or email attribute.">
	</cfif>
	
	<cfhttp url="#myurl#" result="result" timeout="60" throwonerror="true">

	<cfif not isXml(result.filecontent)>
		<cfthrow message="Result wasn't XML" detail="Result: #result.filecontent#">
	</cfif>
	
	<cfset xmlresult = xmlparse(result.filecontent)>
	
	<cfset totalcomments = xmlresult.rss.channel.recordCount.xmlText>
	
	<cfloop index="x" from="1" to="#arrayLen(xmlresult.rss.channel.item)#">
		<cfset item = xmlresult.rss.channel.item[x]>
		<cfset queryAddRow(q)>
		<cfset querySetCell(q,"themeid", item["kuler:commentItem"]["kuler:themeItem"]["kuler:themeID"].xmltext)>
		<cfset querySetCell(q,"comment", item["kuler:commentItem"]["kuler:comment"].xmltext)>
		<cfset querySetCell(q,"author", item["kuler:commentItem"]["kuler:author"].xmltext)>
		<cfset querySetCell(q,"postedat", item["kuler:commentItem"]["kuler:postedAt"].xmltext)>

		<cfset querySetCell(q,"totalcomments", totalcomments)>


			
	</cfloop>	
	<cfreturn q>
</cffunction>

<cffunction name="getHighestRated" access="public" returnType="query" output="false">
	<cfargument name="start" type="numeric" required="false" default="1">
	<cfargument name="max" type="numeric" required="false" default="20">
	<cfargument name="timeSpan" type="numeric" required="false" default="0">
		
	<cfreturn get("rating", arguments.start, arguments.max, arguments.timeSpan)>
</cffunction>

<cffunction name="getPopular" access="public" returnType="query" output="false">
	<cfargument name="start" type="numeric" required="false" default="1">
	<cfargument name="max" type="numeric" required="false" default="20">
	<cfargument name="timeSpan" type="numeric" required="false" default="0">
		
	<cfreturn get("popular", arguments.start, arguments.max, arguments.timeSpan)>
</cffunction>

<cffunction name="getRandom" access="public" returnType="query" output="false">
	<cfargument name="start" type="numeric" required="false" default="1">
	<cfargument name="max" type="numeric" required="false" default="20">
	<cfargument name="timeSpan" type="numeric" required="false" default="0">
		
	<cfreturn get("random", arguments.start, arguments.max, arguments.timeSpan)>
</cffunction>

<cffunction name="getRecent" access="public" returnType="query" output="false">
	<cfargument name="start" type="numeric" required="false" default="1">
	<cfargument name="max" type="numeric" required="false" default="20">
	<cfargument name="timeSpan" type="numeric" required="false" default="0">
		
	<cfreturn get("recent", arguments.start, arguments.max, arguments.timeSpan)>
</cffunction>

<cffunction name="getThemeUrl" access="public" returnType="string" output="false" hint="Utility function to for theme URL">
	<cfargument name="id" type="string" required="true">

	<cfreturn "http://kuler.adobe.com/##themeID/" & arguments.id>
		
</cffunction>

<cffunction name="getThumbUrl" access="public" returnType="string" output="false" hint="Utility function to convert theme ID to thumbnail URL">
	<cfargument name="id" type="string" required="true">

	<cfreturn "http://kuler.adobe.com/kuler/API/rss/png/generateThemePng.cfm?themeid=" & arguments.id>
		
</cffunction>

<cffunction name="load" access="private" returnType="query" output="false" hint="Handles ALL parsing - and it rocks - rocks like a hurricane!">
	<cfargument name="myurl" type="string" required="true">

	<cfset var result = "">
	<cfset var xmlresult = "">
	<cfset var q = queryNew("title,link,id,image,authorid,author,tags,rating,downloads,createdat,editedat,swatches,totalthemes")>
	<cfset var x = "">
	<cfset var item = "">
	<cfset var totaltheme = "">
	<cfset var swatches = "">
	<cfset var swatch = "">
	<cfset var swatchNode = "">
	
	<cfhttp url="#arguments.myurl#" result="result" timeout="60" throwonerror="true">

	<cfif not isXml(result.filecontent)>
		<cfthrow message="Result wasn't XML" detail="Result: #result.filecontent#">
	</cfif>
	
	<cfset xmlresult = xmlparse(result.filecontent)>
	<cfset totaltheme = xmlresult.rss.channel.recordCount.xmlText>
	
	<cfloop index="x" from="1" to="#arrayLen(xmlresult.rss.channel.item)#">
		<cfset item = xmlresult.rss.channel.item[x]>
		<cfset queryAddRow(q)>
		<cfset querySetCell(q,"title", item.enclosure.title.xmltext)>
		<cfset querySetCell(q,"link", item.link.xmltext)>
		<cfset querySetCell(q,"id", item["kuler:themeItem"]["kuler:themeID"].xmltext)>
		<cfset querySetCell(q,"image", item["kuler:themeItem"]["kuler:themeImage"].xmltext)>
		<cfset querySetCell(q,"authorid", item["kuler:themeItem"]["kuler:themeAuthor"]["kuler:authorID"].xmltext)>
		<cfset querySetCell(q,"author", item["kuler:themeItem"]["kuler:themeAuthor"]["kuler:authorLabel"].xmltext)>
		<cfset querySetCell(q,"tags", item["kuler:themeItem"]["kuler:themeTags"].xmltext)>
		<cfset querySetCell(q,"rating", item["kuler:themeItem"]["kuler:themeRating"].xmltext)>
		<cfset querySetCell(q,"downloads", item["kuler:themeItem"]["kuler:themeDownloadCount"].xmltext)>
		<cfset querySetCell(q,"createdat", item["kuler:themeItem"]["kuler:themeCreatedAt"].xmltext)>
		<cfset querySetCell(q,"editedat", item["kuler:themeItem"]["kuler:themeEditedAt"].xmltext)>

		<cfset querySetCell(q,"totalthemes", totaltheme)>

		<!--- swatches is an array of structs --->
		<cfset swatches = arrayNew(1)>
		<cfloop index="y" from="1" to="#arrayLen(item["kuler:themeItem"]["kuler:themeSwatches"]["kuler:swatch"])#">
			<cfset swatchNode = item["kuler:themeItem"]["kuler:themeSwatches"]["kuler:swatch"][y]>
			<cfset swatch = structNew()>
			<cfset swatch.hex = swatchNode["kuler:swatchHexColor"].xmlText>
			<cfset swatch.colormode = swatchNode["kuler:swatchColorMode"].xmlText>
			<cfset swatch.channel1 = swatchNode["kuler:swatchChannel1"].xmlText>
			<cfset swatch.channel2 = swatchNode["kuler:swatchChannel2"].xmlText>
			<cfset swatch.channel3 = swatchNode["kuler:swatchChannel3"].xmlText>
			<cfset swatch.channel4 = swatchNode["kuler:swatchChannel4"].xmlText>
			<cfset swatch.index = swatchNode["kuler:swatchIndex"].xmlText>
			<cfset arrayAppend(swatches, swatch)>
		</cfloop>
		
		<cfset querySetCell(q, "swatches", swatches)>
			
	</cfloop>
	
	<cfreturn q>

</cffunction>

<cffunction name="search" access="public" returnType="query" output="false" hint="Searches Themes">
	<cfargument name="term" type="string" required="false">
	<cfargument name="themeid" type="string" required="false">
	<cfargument name="userid" type="string" required="false">
	<cfargument name="email" type="string" required="false">
	<cfargument name="tag" type="string" required="false">
	<cfargument name="hex" type="string" required="false">
	<cfargument name="title" type="string" required="false">

	<cfargument name="start" type="numeric" required="false" default="1">
	<cfargument name="max" type="numeric" required="false" default="20">
	<cfargument name="timeSpan" type="numeric" required="false" default="0">
	
	<cfset var myurl = "">
	
	<!--- kuler is 0 based for start --->
	<cfif arguments.start lt 0>
		<cfset arguments.start = 0>
	<cfelse>
		<cfset arguments.start = arguments.start - 1>
	</cfif>
	
	<!--- max can't be more than 100 --->
	<cfif arguments.max gt 100>
		<cfset arguments.start = 100>
	</cfif>

	<cfset myurl = variables.baseurl & "rss/search.cfm?startIndex=#arguments.start#&itemsPerPage=#arguments.max#&key=#urlEncodedFormat(variables.apikey)#&timeSpan=#arguments.timeSpan#&&searchQuery=">
	
	<!--- kuler right now supports ONE search type. I will "fix" this later possibly with QofQ --->
	<cfif structKeyExists(arguments,"term")>
		<cfset myurl = myurl & urlEncodedFormat(arguments.term)>
	<cfelseif structKeyExists(arguments,"themeid")>
		<cfset myurl = myurl & "themeID:" & urlEncodedFormat(arguments.themeid)>
	<cfelseif structKeyExists(arguments,"email")>
		<cfset myurl = myurl & "email:" & urlEncodedFormat(arguments.email)>
	<cfelseif structKeyExists(arguments,"tag")>
		<cfset myurl = myurl & "tag:" & urlEncodedFormat(arguments.tag)>
	<cfelseif structKeyExists(arguments,"hex")>
		<cfset myurl = myurl & "hex:" & urlEncodedFormat(arguments.hex)>
	<cfelseif structKeyExists(arguments,"title")>
		<cfset myurl = myurl & "title:" & urlEncodedFormat(arguments.title)>
	<cfelseif structKeyExists(arguments,"userid")>
		<cfset myurl = myurl & "userid:" & urlEncodedFormat(arguments.userid)>
	</cfif>
	
	<cfreturn load(myurl)>
		
</cffunction>

</cfcomponent>