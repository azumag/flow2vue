import Vue from 'vue'
import App from './App.vue'

import VueRouter from 'vue-router'
Vue.use(VueRouter);

import routes from './routes'
const router = new VueRouter({
  routes: routes
});

const app = new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>',
});
