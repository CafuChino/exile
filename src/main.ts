import Vue from 'vue'
import './plugins/axios'
import App from './App.vue'
import router from './router'
import store from './store'
import './plugins/iview.js'
import VueCropper from 'vue-cropper'
import * as Sentry from "@sentry/vue";

Vue.config.productionTip = false
Vue.use(VueCropper)

Sentry.init({
  Vue,
  dsn: "https://a59c6bb03f92a526badce516400b6386@o4509274780205056.ingest.de.sentry.io/4510345032106064",
  // Setting this option to true will send default PII data to Sentry.
  // For example, automatic IP address collection on events
  sendDefaultPii: true
});

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
