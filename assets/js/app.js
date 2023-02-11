// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

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
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


import Draw from 'draw-on-canvas'

// Create a new hook Hooks object
let Hooks = {}

// registering the Hook object in the LiveSocket:
let LiveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Adding a new Draw Hook
Hooks.Draw = {}

// we need to implement the mounted function, which is called when the hook is mounted
//This is where we set up the Canvas
Hooks.Draw = {
    mounted() {
        this.draw = new Draw(this.el, 384, 384, {
            backgroundColor: "black",
            strokeColor: "white",
            strokeWeight: 10
        })

        // handleEvent, that listens for the reset event, and resets the canvas:
        this.handleEvent("reset", () => {
            this.draw.reset()
        })

        //we add another handleEvent
        // This grabs the contents of the canvas as a data URL and sends it to the server using pushEvent:
        this.handleEvent("predict", () => {
            this.pushEvent("image", this.raw.canvas.toDataURL('image/png'))
        })
    }
}
