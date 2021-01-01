/*
h3collapse  Replace h3 tags with "collapsible" buttons and "content" divs

Copyright 2020-2021 The MathWorks, Inc.
*/
document.addEventListener("DOMContentLoaded", function () {
  let mains = document.body.getElementsByTagName("main");
  for (let i = 0; i < mains.length; i++) {
    let main = mains[i];
    let tempDiv = document.createElement("div"); // create temp div
    let nextParent = tempDiv; // initialize: append next child to div
    while (main.hasChildNodes()) {
      let child = main.childNodes[0];
      switch (child.nodeName.toLowerCase()) {
        case "h1":
        case "h2":
          tempDiv.appendChild(child); // append child to div
          nextParent = tempDiv; // append next child to div
          break;
        case "h3":
          let button = document.createElement("button"); // create new button
          button.className = "collapsible";
          while (child.hasChildNodes()) {
            button.appendChild(child.childNodes[0]); // move h3 children to new button
          }
          let content = document.createElement("div"); // create subdiv
          content.className = "content";
          tempDiv.appendChild(button); // append button to div
          tempDiv.appendChild(content); // append subdiv to div
          child.remove(); // remove h3
          nextParent = content; // append next child to subdiv
          break;
        default:
          nextParent.appendChild(child); // append child to div or subdiv
      }
    }
    while (tempDiv.hasChildNodes()) {
      main.appendChild(tempDiv.childNodes[0]); // move temp div children back to main
    }
    tempDiv.remove(); // remove temp div
  }
  let collapsibles = document.getElementsByClassName("collapsible");
  for (let i = 0; i < collapsibles.length; i++) {
    collapsibles[i].addEventListener("click", function () {
      this.classList.toggle("active");
      let content = this.nextElementSibling;
      if (content.style.maxHeight) {
        content.style.maxHeight = null;
      } else {
        content.style.maxHeight = content.scrollHeight + "px";
      }
    });
  }
})