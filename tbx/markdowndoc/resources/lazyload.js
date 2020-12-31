/*
lazyload  Lazily load items of class "lazy" by populating setting their src from their dataset.src.

Copyright 2020-2021 The MathWorks, Inc.
*/
document.addEventListener("DOMContentLoaded", function () {
  let lazyloadImages;
  if ("IntersectionObserver" in window) {
    lazyloadImages = document.querySelectorAll(".lazy");
    let imageObserver = new IntersectionObserver(function (entries, observer) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          let image = entry.target;
          image.src = image.dataset.src;
          image.classList.remove("lazy");
          imageObserver.unobserve(image);
        }
      });
    });
    lazyloadImages.forEach(function (image) {
      imageObserver.observe(image);
    });
  }
})
