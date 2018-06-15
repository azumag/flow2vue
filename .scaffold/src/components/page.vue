<template>
  <div id="PAGE_ID">
    <h2>PAGE_NAME</h2>
    <p>BODY</p>
    <p>===FORM===</p>
    <p>===LINK===</p>
  </div>
</template>

<script>
export default {
  name: 'page',
  data: () => (
    ===DATA===
  ), 
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
