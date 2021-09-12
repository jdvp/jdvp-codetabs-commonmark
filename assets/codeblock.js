function selectTab(codeLangClass, tabClass, tabIndex) {
    var tabbedItemsWithMatchingLanguage = [...new Set(Array.prototype.slice.call(document.getElementsByClassName(codeLangClass))
        .map(item => item.parentNode))];

    tabbedItemsWithMatchingLanguage
        .flatMap(item => Array.prototype.slice.call(item.children))
        .forEach(item => item.classList.remove("active-tab"));


    tabbedItemsWithMatchingLanguage.forEach((element) => {
         Array.prototype.slice.call(element.children)
            .filter( item => item.matches("." + codeLangClass))[0]
            .classList.add("active-tab");
    });

    var tabsMatchingTabClass = [...new Set(Array.prototype.slice.call(document.getElementsByClassName(tabClass)))];

    tabsMatchingTabClass
        .flatMap(item => Array.prototype.slice.call(item.children))
        .forEach(item => item.classList.remove("active-tab"));


    tabsMatchingTabClass.forEach((tab) => {
        Array.prototype.slice.call(tab.children)[tabIndex].classList.add("active-tab");
    });
};

function copyText(codeBlockClass) {
    var copiedText = document.getElementsByClassName(codeBlockClass)[0].innerText;
    navigator.clipboard.writeText(copiedText);
    var snackbar = document.getElementById("code_copied_snackbar");
    snackbar.classList.add("show")
    setTimeout(function() { snackbar.classList.remove("show"); }, 3000);
};

var darkModeMatcher = window.matchMedia("(prefers-color-scheme: dark)");

darkModeMatcher.addListener(matcher => {
    localStorage.setItem("code-block-theme", "");
    updateTheme(false);
});

function updateTheme(switchTheme) {
    var theme = localStorage.getItem("code-block-theme");

    var isCurrentThemeDark = false;
    if (theme == "dark") {
        isCurrentThemeDark = true;
    } else if (theme == "light") {
        isCurrentThemeDark = false;
    } else if (darkModeMatcher.matches) {
        isCurrentThemeDark = true;
    } else {
        isCurrentThemeDark = false;
    }

    var updatedTheme = "dark";
    /* This is performing a logical XNOR */
    if (isCurrentThemeDark == switchTheme) {
        updatedTheme = "light";
    }

    document.documentElement.setAttribute("data-code-block-theme", updatedTheme);
    localStorage.setItem("code-block-theme", updatedTheme);
};

updateTheme(false);

window.onload = function() { updateTheme(false); };