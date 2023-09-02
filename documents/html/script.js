document.addEventListener('DOMContentLoaded', (event) => {
    const mainMenu = [
        "☁️ Remote Systems",
        "🏣 Local System",
        "🔑 SSH Key Management",
        "⚙️ Settings",
        "❓ Help Manual",
        "⏹️ Exit",
    ];

    const menuContainer = document.getElementById("menuContainer");

    // Render menu
    function renderMenu(menu) {
        menuContainer.innerHTML = "";
        menu.forEach((item, index) => {
            const menuItem = document.createElement("div");
            menuItem.innerText = item;
            menuItem.className = index === 0 ? 'selected' : '';
            menuContainer.appendChild(menuItem);
        });
    }

    renderMenu(mainMenu);

    let selectedIndex = 0;

    // Listen to arrow keys and Enter
    document.addEventListener('keydown', function(event) {
        if (event.code === 'ArrowUp' && selectedIndex > 0) {
            selectedIndex--;
        } else if (event.code === 'ArrowDown' && selectedIndex < mainMenu.length - 1) {
            selectedIndex++;
        } else if (event.code === 'Enter') {
            // Implement action on Enter
            console.log(`Selected: ${mainMenu[selectedIndex]}`);
        }

        Array.from(menuContainer.children).forEach((item, index) => {
            item.className = index === selectedIndex ? 'selected' : '';
        });
    });
});
