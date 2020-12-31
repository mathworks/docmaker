document.addEventListener("DOMContentLoaded", function() {
  let links = document.getElementsByTagName("a"); // get links
  for(let i=0;i<links.length;i++) { // loop over links
    let href = links[i].getAttribute("href"); // get href
    if(href.toLowerCase().endsWith(".md")) { // ends with .md
      let j = href.toLowerCase().lastIndexOf(".md"); // string before .md
      href = href.substring(0,j) + ".html"; // append .html
      links[i].setAttribute("href",href); // set href
    }
  }
})