import Vue from 'vue'
import VueBrando from 'brandojs'

import Admin from 'brandojs/src/Admin'
import router from 'brandojs/src/router'
import routes from './routes'
import menuSections from './menus'
import i18n from 'brandojs/src/i18n'
import app from './config'

Vue.use(VueBrando, { app, menuSections })

new Vue({
  router,
  i18n,
  data: { ready: false },
  render: h => h(Admin),
  created() {
    this.$router.addRoutes(routes)
  }
}).$mount('#app')
