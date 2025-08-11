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
import Alpine from "alpinejs"
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Define Hooks before using it
const Hooks = {
  BackHook: {
    mounted() {
      this.handleEvent("goBack", ({flash}) => {  // Accept flash from the event
        // Store the flash message and type
        if (flash) {
          localStorage.setItem('flash_message', flash.message);
          localStorage.setItem('flash_type', flash.type);
        }
        history.go(-1);
      });

      // Check for stored flash message on mount
      const flashMessage = localStorage.getItem('flash_message');
      const flashType = localStorage.getItem('flash_type');

      if (flashMessage) {
        // Push the flash to LiveView
        this.pushEvent("restore_flash", {
          message: flashMessage,
          type: flashType
        });

        // Clear the stored flash
        localStorage.removeItem('flash_message');
        localStorage.removeItem('flash_type');
      }
    }
  }
};

window.Alpine = Alpine;
Alpine.start();

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks  // Now Hooks is defined before being used here
})

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())
liveSocket.connect()

window.liveSocket = liveSocket

window.addEventListener("phx:js-exec", ({detail}) => {
  document.querySelectorAll(detail.to).forEach(el => {
    liveSocket.execJS(el, el.getAttribute(detail.attr))
  })
})
