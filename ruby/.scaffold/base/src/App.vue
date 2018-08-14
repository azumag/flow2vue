<template>
  <div id="app">
  <!-- VUETIFY_START
    <v-app id="inspire">
  VUETIFY_START -->
  <!-- VUETIFY_NAVBAR
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
      </v-list>
    </v-navigation-drawer>
  VUETIFY_NAVBAR -->
  <!-- VUETIFY_TOOLBAR
    <v-toolbar color="indigo" dark fixed app>
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
      <v-toolbar-title >APP_TITLE</v-toolbar-title>
    </v-toolbar>
  VUETIFY_TOOLBAR -->
  <!-- SIMPLE_NAVBAR -->
    <router-view></router-view>
  <!-- VUETIFY-FOOTER
    <v-footer color="indigo" app inset>
      <span class="white--text"></span>
    </v-footer>
  VUETIFY-FOOTER -->
  <!-- VUETIFY-END
    </v-app>
  VUETIFY-END -->
  </div>
</template>

<script>
export default {
  name: 'app',
  data () {
    return {
    }
  }
}
</script>

<style>
</style>
