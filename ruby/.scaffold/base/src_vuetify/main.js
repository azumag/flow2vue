import Vue from 'vue'
import App from './App.vue'

import 'vue-awesome/icons/flag'
import 'vue-awesome/icons'
import Icon from 'vue-awesome/components/Icon'
Vue.component('icon', Icon)
Vue.config.productionTip = false

import VueRouter from 'vue-router'
Vue.use(VueRouter);

import Vuetify from 'vuetify'
Vue.use(Vuetify)

import routes from './routes'
const router = new VueRouter({
  routes: routes
});

import 'vuetify/dist/vuetify.min.css'

import 'material-design-icons-iconfont/dist/material-design-icons.css'

const app = new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>',
});
