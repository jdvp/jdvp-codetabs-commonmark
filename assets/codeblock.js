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
};