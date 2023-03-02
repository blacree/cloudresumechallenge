"use strict";

if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
  document.body.classList.add("dark");
}


// function httpGet(theUrl){
//   var xmlHttp = new XMLHttpRequest();
//   xmlHttp.open( "GET", theUrl, false ); // false for synchronous request
//   xmlHttp.send( null );
//   return xmlHttp.responseText;
// }

function httpGetAsync(theUrl, callback)
{
  var xmlHttp = new XMLHttpRequest();
  xmlHttp.onreadystatechange = function() { 
      if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
          callback(xmlHttp.responseText);
  }
  xmlHttp.open("GET", theUrl, true); // true for asynchronous 
  xmlHttp.send(null);
}

function rendercountonpage(response){
  console.log(response);
  var counterContainer = document.querySelector(".visitor_counter");
  counterContainer.innerHTML = "Visit Counter: " + response.replaceAll('\"', '');
}

if (localStorage.getItem("crc_page_viewed") === null){
  localStorage.setItem("crc_page_viewed", true);
  var Url = "https://crc-function-app.azurewebsites.net/api/crc_function?update=true";
  httpGetAsync(Url, rendercountonpage);
}
else {
  var Url = "https://crc-function-app.azurewebsites.net/api/crc_function?update=false";
  httpGetAsync(Url, rendercountonpage);
}



// if (localStorage.getItem("page_view") === undefined ) {
//   var visitCount = 1;
//   localStorage.setItem("page_view", 1);
//   counterContainer.innerHTML = "Visit Counter: " + visitCount;
// }
// else {
//   var visitCount = localStorage.getItem("page_view");
//   visitCount = Number(visitCount) + 1;
//   localStorage.setItem("page_view", visitCount);
//   counterContainer.innerHTML = "Visit Counter: " + visitCount;
// }
