import Vue from 'vue'
import App from './App.vue'
import routes from './routes'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const router = new VueRouter({
  routes: routes
})

// eslint-disable-next-line
const app = new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
