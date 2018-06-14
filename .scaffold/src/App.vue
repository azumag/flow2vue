<template>
  <div id="app">
    <v-app id="inspire">
      <v-navigation-drawer fixed v-model="drawer" app>
        <v-list dense>
          <v-list-tile @click="$router.push('/')">
            <v-list-tile-action>
              <v-icon>home</v-icon>
            </v-list-tile-action>
            <v-list-tile-content>
              <v-list-tile-title>
                Home
              </v-list-tile-title>
            </v-list-tile-content>
          </v-list-tile>
          <v-list-tile @click="">
            <v-list-tile-action>
              <v-icon>contact_mail</v-icon>
            </v-list-tile-action>
            <v-list-tile-content>
              <v-list-tile-title>Contact</v-list-tile-title>
            </v-list-tile-content>
          </v-list-tile>
        </v-list>
      </v-navigation-drawer>
      <v-toolbar color="indigo" dark fixed app>
        <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
        <v-toolbar-title >APP_TITLE</v-toolbar-title>
      </v-toolbar>
      <v-content>
        <v-snackbar
        :timeout="timeout"
        :top="y === 'top'"
        :bottom="y === 'bottom'"
        :right="x === 'right'"
        :left="x === 'left'"
        :multi-line="mode === 'multi-line'"
        :vertical="mode === 'vertical'"
        v-model="snackbar"
        >
          {{ notificationMsg }}
          <v-btn flat color="pink" @click.native="snackbar = false">Close</v-btn>
        </v-snackbar>
      <v-container fluid>
        <v-alert
        v-model="notificationVisible"
        :type="notificationType"
        dismissible
        transition="slide-x-transition"
        >
        {{ notificationMsg }}
      </v-alert>
      <router-view
        @notify="setNotification"
        @snackbar="setSnackbar">
      </router-view>
    </v-container>
  </v-content>
  <v-footer color="indigo" app inset>
    <span class="white--text">&copy; 2018 Around The World Trading </span>
  </v-footer>
</v-app>
</div>
</template>

<script>
export default {
  name: 'app',
  data () {
    return {
      notificationType: 'info',
      notificationMsg: '',
      notificationVisible: false,
      drawer: null,
      snackbar: false,
      y: 'top',
      x: null,
      mode: '',
      timeout: 6000,
    }
  },
  methods:{
    setNotification(msg, type) {
      this.notificationMsg = msg;
      this.notificationType = type;
      this.notificationVisible = true;
    },
    setSnackbar(msg) {
      this.notificationMsg = msg;
      this.snackbar = true
    },
    disableNotification() {
      this.notificationMsg = ''
    }
  }
}
</script>

<style>
</style>
