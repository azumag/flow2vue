<template>
  <div id="page">
    <h2>PAGE_NAME</h2>
    <p>BODY</p>
    ===LINK===
  </div>
</template>

<script>
export default {
  name: 'page',
  data: () => ({
    valid: true,
    email: '',
    emailRules: [
      v => !!v || 'Email is required',
      v => /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(v) || 'Email must be valid'
    ],
    password: '',
    passwordRules: [
      v => !!v || 'Password is required'
    ],
    mask: true,
  }),

  methods: {
    submit () {
      if (this.$refs.form.validate()) {
        // Native form submission is not yet supported
        // axios.post('/home', {
        //   email: this.email,
        //   password: this.password

        // })
        this.$router.push('/home')
      }
    }
  }
}
</script>

<style></style>
