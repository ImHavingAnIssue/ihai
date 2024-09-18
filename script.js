// script.js
document.addEventListener('scroll', function() {
    const scrollPosition = window.pageYOffset;
    const background = document.querySelector('.parallax-background');
    background.style.transform = 'translateY(' + scrollPosition * 0.5 + 'px)';
});
