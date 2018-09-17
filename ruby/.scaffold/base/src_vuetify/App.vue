<template>
  <v-app id="inspire" dark>
    <v-navigation-drawer fixed v-model="drawer" app>
      <v-list dense>
        <!-- NAVBAR -->
      </v-list>
    </v-navigation-drawer>
    <v-toolbar fixed app>
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
      <v-toolbar-title >APP_TITLE</v-toolbar-title>
    </v-toolbar>
    <v-content>
      <router-view></router-view>
    </v-content>
    <v-footer app inset>
      <span class="white--text"></span>
    </v-footer>
  </v-app>
</template>

<script>
export default {
  name: 'app',
  data () {
    return {
      drawer: true
    }
  }
}
</script>

<style>
</style>
