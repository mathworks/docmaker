document.addEventListener("DOMContentLoaded", function () {
  let mains = document.body.getElementsByTagName("main");
  for (let i = 0; i < mains.length; i++) {
    let main = mains[i];
    let children = main.childNodes;
    let div = document.createElement("div");
    let parent = div;
    while (children.length > 0) {
      var child = children[0];
      var childName = child.nodeName.toLowerCase();
      switch (childName) {
        case "h1":
        case "h2":
        case "h3":
          if (parent != div) {
            parent = div;
          }
      }
      switch (childName) {
        case "h3":
          let button = document.createElement("button");
          button.className = "collapsible";
          while (child.childNodes.length > 0) {
            console.log("Add");
            button.appendChild(child.childNodes[0]);
          }
          let content = document.createElement("div");
          content.className = "content";
          div.appendChild(button);
          div.appendChild(content);
          child.remove();
          parent = content;
          break;
        default:
          console.log("Move " + child.nodeName);
          parent.appendChild(child);
      }
    }
    main.appendChild(div);
  }
  var collapsible = document.getElementsByClassName("collapsible");
  for (let i = 0; i < collapsible.length; i++) {
    collapsible[i].addEventListener("click", function () {
      this.classList.toggle("active");
      var content = this.nextElementSibling;
      if (content.style.maxHeight) {
        content.style.maxHeight = null;
      } else {
        content.style.maxHeight = content.scrollHeight + "px";
      }
    });
  }

})

function printElements(elements) {
  var s = ""; // initialize
  for (let i = 0; i < elements.length; i++) {
    s = s + "." + elements[i].nodeName;
  }
  console.log(s);
}

/*
      var child = children[j];
      var tag = child.nodeName.toLowerCase();
      switch (tag) {
        case "h1":
        case "h2":
        case "h3":
          console.log("Tag level " + tag);
          var childLevel = parseInt(tag[1]);
*/

/*
if(childLevel>parentLevel) {
  for(let k=parentLevel;k<childLevel;k++) {
    var div = document.createElement("div");
    div.setAttribute("class",tag);
    parent.appendChild(div);
    parent = div;
    parentLevel = k+1;
  }
} else if (childLevel<parentLevel) {
  for(let k=parentLevel;k>childLevel;k--) {
    parent = parent.parentElement;
    parentLevel = k-1;
  }
} else {
  var div = document.createElement("div");
  div.setAttribute("class",tag);
  parent.parentElement.appendChild(div);
  parent = div;
}
*/
