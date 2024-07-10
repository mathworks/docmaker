/*
md2html  Replace .md links with .html links

Copyright 2020-2024 The MathWorks, Inc.
*/
document.addEventListener("DOMContentLoaded", function() {
  let links = document.getElementsByTagName("a"); // get links
  for(let i=0;i<links.length;i++) { // loop over links
    let href = links[i].getAttribute("href"); // get href
    let j = href.lastIndexOf("#"); // last #
    let lhs; // href before last #
    let rhs; // href from last #
    if(j == -1) { // no #
      lhs = href; // all
      rhs = ""; // nothing
    } else {
      lhs = href.substring(0,j); // before
      rhs = href.substring(j); // after
    }
    if(lhs.endsWith(".md")) { // ends with .md
      let k = lhs.lastIndexOf(".md"); // last .md
      href = lhs.substring(0,k) + ".html" + rhs; // combine
      links[i].setAttribute("href",href); // set href
    }
  }
})