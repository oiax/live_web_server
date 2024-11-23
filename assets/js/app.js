// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

const Hooks = {};

Hooks.ShowModalSignOut = {
  mounted() {
    this.activate();
  },
  updated() {
    this.activate();
  },
  activate() {
    const openButton = document.getElementById("open-sign-out-modal");
    const closeButton = document.getElementById("close-sign-out-modal");

    openButton.addEventListener("click", (e) => {
      e.stopPropagation();
      document.getElementById("sign-out-dialog").showModal();
    });

    closeButton.addEventListener("click", (e) => {
      e.stopPropagation();
      document.getElementById("sign-out-dialog").close();
    });
  },
};

Hooks.ShowUserMenu = {
  mounted() {
    this.activate();
  },
  updated() {
    this.activate();
  },
  activate() {
    const userMenu = document.getElementById("user-menu");
    const visible = this.el.dataset.visible === "true";
    if (visible) {
      userMenu.style.display = "block";
      setTimeout(() => {
        userMenu.classList.add("show");
      }, 10);
    } else {
      userMenu.classList.remove("show");
      setTimeout(() => {
        userMenu.style.display = "none";
      }, 300);
    }
    document.addEventListener("click", (event) => {
      if (
        !userMenu.contains(event.target) &&
        event.target.id !== "open-user-menu"
      ) {
        userMenu.classList.remove("show");
        setTimeout(() => {
          userMenu.style.display = "none";
        }, 300);
      }
    });
  },
};

document.addEventListener("DOMContentLoaded", () => {
  const openUserMenuButton = document.getElementById("open-user-menu");

  openUserMenuButton.addEventListener("click", (e) => {
    e.stopPropagation();
    const userMenu = document.getElementById("user-menu");
    const isVisible = userMenu.style.display === "block";
    userMenu.style.display = isVisible ? "none" : "block";
    if (!isVisible) {
      setTimeout(() => {
        userMenu.classList.add("show");
      }, 10);
    } else {
      userMenu.classList.remove("show");
    }
  });
});

document.addEventListener("click", (event) => {
  const userMenu = document.getElementById("user-menu");
  if (userMenu && !userMenu.contains(event.target) && event.target.id !== "open-user-menu") {
    userMenu.classList.remove("show");
    setTimeout(() => {
      userMenu.style.display = "none";
    }, 300);
  }
});

Hooks.ShowPassword = {
  mounted() {
    this.activate();
  },
  updated() {
    this.activate();
  },
  activate() {
    const showPassword = document.getElementById("show-password");
    const passwordInput = document.getElementById("administrator_password");
    const changePasswordInput = document.getElementById("change_password");

    showPassword.addEventListener("click", (e) => {
      const type = showPassword.checked ? "text" : "password";
      if (passwordInput != null) {
        passwordInput.setAttribute("type", type);
      }
      if (changePasswordInput != null) {
        changePasswordInput.setAttribute("type", type);
      }
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

Hooks.FlashMessage = {
  mounted() {
    setTimeout(() => {
      this.el.style.opacity = "0";
      setTimeout(() => {
        this.el.remove();
        document.getElementById("overlay").remove();
      }, 1000);
    }, 3000);
  },
};

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
