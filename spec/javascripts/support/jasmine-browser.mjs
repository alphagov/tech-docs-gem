export default {
  srcDir: ".",
  srcFiles: [
    "node_modules/govuk-frontend/dist/all.bundle.js",
    "lib/assets/javascripts/_vendor/jquery.js",
    "lib/assets/javascripts/_vendor/jquery.mark.js",
    "spec/javascripts/helpers/lunr.min.js",
    "lib/assets/javascripts/_vendor/lodash.js",
    "lib/assets/javascripts/_govuk/modules.js",
    "lib/assets/javascripts/_modules/*.js"
  ],
  specDir: "spec/javascripts",
  specFiles: [
    "!/helpers/*.js",
    "!/support/*.js",
    "**/*[sS]pec.js"
  ],
  helpers: [
    "helpers/**/*.js"
  ],
  env: {
    stopSpecOnExpectationFailure: false,
    stopOnSpecFailure: false,
    random: true
  },

  // For security, listen only to localhost. You can also specify a different
  // hostname or IP address, or remove the property or set it to "*" to listen
  // to all network interfaces.
  listenAddress: "localhost",

  // The hostname that the browser will use to connect to the server.
  hostname: "localhost",

  browser: {
    name: "headlessChrome"
  }
};
