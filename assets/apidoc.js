document.addEventListener("DOMContentLoaded", function () {
  
  let mains = document.body.getElementsByTagName("main");
  for (let i = 0; i < mains.length; i++) {
    let main = mains[i];
    let div = document.createElement("div"); // create temp div
    let parent = div; // initialize: append next child to div
    while (main.hasChildNodes()) {
      let child = main.childNodes[0];
      switch (child.nodeName.toLowerCase()) {
        case "h1":
        case "h2":
          div.appendChild(child); // append child to div
          parent = div; // append next child to div
          break;
        case "h3":
          let button = document.createElement("button"); // create new button
          button.className = "collapsible";
          while (child.hasChildNodes()) {
            button.appendChild(child.childNodes[0]); // move h3 children to new button
          }
          let content = document.createElement("div"); // create subdiv
          content.className = "content";
          div.appendChild(button); // append button to div
          div.appendChild(content); // append subdiv to div
          child.remove(); // remove h3
          parent = content; // append next child to subdiv
          break;
        default:
          parent.appendChild(child); // append child to div or subdiv
      }
    }
    while (div.hasChildNodes()) {
      main.appendChild(div.childNodes[0]); // move temp div children back to main
    }
    div.remove(); // remove temp div
  }

  let collapsible = document.getElementsByClassName("collapsible");
  for (let i = 0; i < collapsible.length; i++) {
    collapsible[i].addEventListener("click", function () {
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