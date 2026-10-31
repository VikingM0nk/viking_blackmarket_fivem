console.log("[Blackmarket NUI] Loaded");

const ui = document.getElementById("blackmarket-container");
const itemsContainer = document.querySelector(".items-container");
const cartItemsDiv = document.getElementById("cart-items");
const cartTotalDiv = document.getElementById("cart-total");

let currentMarket = null;
let cart = [];
let INVENTORY_TYPE = "custom";

function getItemImage(itemName) {
    switch (INVENTORY_TYPE) {
        case "ox":
            return `nui://ox_inventory/web/images/${itemName}.png`;

        case "qb":
            return `nui://qb-inventory/html/images/${itemName}.png`;

        case "qs":
            return `nui://qs-inventory/html/images/${itemName}.png`;

        case "custom":
            return `images/${itemName}.png`;

        default:
            return "";
    }
}




// Hide on load
ui.style.display = "none";

/* ========================= */
/* OPEN / CLOSE */
/* ========================= */
window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "open") {
        INVENTORY_TYPE = data.inventory || "custom";
        currentMarket = data.market;
        document.getElementById("marketName").innerText = currentMarket.name;

        cart = [];
        updateCart();

        itemsContainer.innerHTML = "";

        currentMarket.items.forEach(item => {
            const div = document.createElement("div");
            div.className = "item";

           div.innerHTML = `
    <div class="item-top">
        <img src="${getItemImage(item.item)}" 
             onerror="this.src='https://via.placeholder.com/64?text=?'" 
             class="item-image">
             
        <div class="item-info">
            <h3>${item.label}</h3>
            <p>$${item.price.toLocaleString()}</p>
        </div>
    </div>

    <div class="quantity">
        <button class="minus">-</button>
        <input type="number" value="1" min="1">
        <button class="plus">+</button>
    </div>

    <button class="buy-btn">Add to Cart</button>
`;

            const input = div.querySelector("input");

            div.querySelector(".minus").addEventListener("click", () => {
                if (input.value > 1) input.value--;
            });

            div.querySelector(".plus").addEventListener("click", () => {
                input.value++;
            });

            div.querySelector(".buy-btn").addEventListener("click", () => {
                addToCart(item, parseInt(input.value));
            });

            itemsContainer.appendChild(div);
        });

        ui.style.display = "block";
    }

    if (data.action === "close") {
        closeUI();
    }
});

/* ========================= */
/* CART SYSTEM */
/* ========================= */

function addToCart(item, quantity) {
    const existing = cart.find(i => i.item === item.item);

    if (existing) {
        existing.quantity += quantity;
    } else {
        cart.push({
            item: item.item,
            label: item.label,
            price: item.price,
            quantity: quantity
        });
    }

    updateCart();
}

function removeFromCart(itemName) {
    cart = cart.filter(i => i.item !== itemName);
    updateCart();
}

function updateCart() {
    cartItemsDiv.innerHTML = "";
    let total = 0;

    cart.forEach(i => {
        total += i.price * i.quantity;

        const div = document.createElement("div");
        div.className = "cart-item";
        div.innerHTML = `
            ${i.label} x${i.quantity}
            <span style="float:right; cursor:pointer; color:red;">✖</span>
        `;

        div.querySelector("span").addEventListener("click", () => {
            removeFromCart(i.item);
        });

        cartItemsDiv.appendChild(div);
    });

    cartTotalDiv.innerText = `Total: $${total.toLocaleString()}`;
}

/* ========================= */
/* CHECKOUT */
/* ========================= */

function checkout() {
    if (cart.length === 0) return;

    fetch(`https://${GetParentResourceName()}/checkout`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            market: currentMarket.name,
            cart: cart
        })
    });

    cart = [];
    updateCart();
    
}

/* ========================= */
/* CLOSE */
/* ========================= */

function closeUI() {
    ui.style.display = "none";

    fetch(`https://${GetParentResourceName()}/close`, {
        method: "POST"
    });
}

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
        closeUI();
    }
});
